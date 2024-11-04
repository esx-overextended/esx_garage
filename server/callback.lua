lib.callback.register("esx_garage:getOwnedVehicles", function(source, garageKey)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    if not IsPlayerInGarageZone(xPlayer.source, garageKey) or not IsPlayerAuthorizedToAccessGarage(xPlayer, garageKey) then return CheatDetected(xPlayer.source) end

    local query = [[
    SELECT ov.`id`, ov.`plate`, ov.`vehicle`, ov.`model`, ov.`stored`, ov.`garage`, iv.`impounded_at`
    FROM `owned_vehicles` AS ov
    LEFT JOIN `impounded_vehicles` AS iv ON ov.`id` = iv.`id`
    WHERE ov.`owner` = ? AND ov.`job` IS NULL]]
    local dbResults = MySQL.rawExecute.await(query, { xPlayer.getIdentifier() })

    return GenerateVehicleDataAndContextFromQueryResult(dbResults, garageKey)
end)

lib.callback.register("esx_garage:getSocietyVehicles", function(source, garageKey)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    if not IsPlayerInGarageZone(xPlayer.source, garageKey) or not IsPlayerAuthorizedToAccessGarage(xPlayer, garageKey) or not Config.Garages[garageKey].Groups then return CheatDetected(xPlayer.source) end

    local currentGarageGroups = {}
    local _type = type(Config.Garages[garageKey].Groups)

    if _type == "string" then
        currentGarageGroups[1] = Config.Garages[garageKey].Groups
    elseif _type == "table" then
        if table.type(Config.Garages[garageKey].Groups) == "array" then
            for i = 1, #Config.Garages[garageKey].Groups do
                currentGarageGroups[#currentGarageGroups + 1] = Config.Garages[garageKey].Groups[i]
            end
        else
            for groupName in pairs(Config.Garages[garageKey].Groups) do
                currentGarageGroups[#currentGarageGroups + 1] = groupName
            end
        end
    end

    if not next(currentGarageGroups) then return print(("[^1ERROR^7] Mulfunctioned data for garage (^5%s^7) as per Player (^5%s^7) request. Expected groups but received nothing!"):format(garageKey, xPlayer.source)) end

    local query = string.format([[SELECT ov.`id`, ov.`plate`, ov.`vehicle`, ov.`model`, ov.`stored`, ov.`garage`, iv.`impounded_at`
    FROM `owned_vehicles` AS ov
    LEFT JOIN `impounded_vehicles` AS iv ON ov.`id` = iv.`id`
    WHERE (ov.`owner` = ? OR ov.`owner` = '' OR ov.`owner` IS NULL) AND ov.`job` IN (%s)]], ("'%s'"):format(table.concat(currentGarageGroups, "', '")))
    local dbResults = MySQL.rawExecute.await(query, { xPlayer.getIdentifier() })

    return GenerateVehicleDataAndContextFromQueryResult(dbResults, garageKey)
end)

lib.callback.register("esx_garage:transferVehicle", function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or type(data) ~= "table" then return end

    if not IsPlayerInGarageZone(xPlayer.source, data.garageKey) or not IsPlayerAuthorizedToAccessGarage(xPlayer, data.garageKey) then return CheatDetected(xPlayer.source) end

    if xPlayer.getMoney() < Config.TransferPrice then return xPlayer.showNotification(("You don't have $%s money in your pocket!"):format(Config.TransferPrice), "error") end

    xPlayer.removeMoney(Config.TransferPrice, ("Transferring of %s vehicle (%s) to %s"):format(data.vehicleName, data.plate, Config.Garages[data.garageKey].Label))

    return MySQL.update.await("UPDATE `owned_vehicles` SET `garage` = ? WHERE `id` = ? AND `owner` = ?", { data.garageKey, data.vehicleId, xPlayer.getIdentifier() })
end)

lib.callback.register("esx_garage:getImpoundedVehicles", function(source, impoundKey)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    if not IsPlayerInImpoundZone(xPlayer.source, impoundKey) then return CheatDetected(xPlayer.source) end

    local query = [[
    SELECT ov.`id`, ov.`plate`, ov.`job`, ov.`model`, ov.`vehicle`, iv.`impounded_at`, iv.`release_fee`, CASE WHEN NOW() >= iv.`release_date` THEN 1 ELSE 0 END AS `is_release_date_passed`,
    TIMESTAMPDIFF(SECOND, NOW(), iv.`release_date`) AS `release_date_second_until`
    FROM `owned_vehicles` AS `ov`
    LEFT JOIN `impounded_vehicles` AS `iv` ON ov.`id` = iv.`id`
    WHERE (ov.`owner` = ? or ov.`owner` IS NULL or ov.`owner` = "") AND (ov.`stored` = 0 or ov.`stored` IS NULL)]]
    local dbResults = MySQL.rawExecute.await(query, { xPlayer.getIdentifier() })

    local vehicles, contextOptions, count = {}, {}, 0
    local worldVehicles = GetAllVehicles()
    local worldVehiclesCount = #worldVehicles

    for i = 1, #dbResults do
        local dbResult = dbResults[i]
        dbResult.vehicle = json.decode(dbResult.vehicle)

        if not DoesPlayerHaveAccessToGroup(xPlayer, dbResult.job) then goto skipLoop end

        if (not dbResult.model or dbResult.model == "") and dbResult.vehicle?.model then -- probably just migrated from esx-legacy therefore dbResult.model is empty...
            for vModel, vData in pairs(ESX.GetVehicleData()) do
                if vData.hash == dbResult.vehicle.model then
                    dbResult.model = vModel
                    break
                end
            end
        end

        if (not dbResult.model or dbResult.model == "") then
            ESX.Trace(("Vehicle hash (^1%s^7) for Vehicle ID (^5%s^7) from database is invalid \nEnsure vehicle exists in ^2'@es_extended/files/vehicles.json'^7"):format(dbResult.vehicle?.model, dbResult.id), "warning", true)
            goto skipLoop
        end

        local modelData = ESX.GetVehicleData(dbResult.model)

        if not DoesZoneAcceptVehicleType("impound", impoundKey, modelData?.type) then
            goto skipLoop
        end

        local canGetVehicle = true
        local canReleaseVehicle = (dbResult.impounded_at == nil and true) or dbResult.is_release_date_passed == 1

        for j = 1, worldVehiclesCount do
            local worldVehicle = worldVehicles[j]
            local worldVehiclePlate = ESX.Math.Trim(GetVehicleNumberPlateText(worldVehicle))

            if worldVehiclePlate == dbResult.vehicle?.plate or worldVehiclePlate == dbResult.plate then
                if GetVehiclePetrolTankHealth(worldVehicle) <= 0 or GetVehicleBodyHealth(worldVehicle) <= 0 or GetVehicleEngineHealth(worldVehicle) <= 0 then
                    ESX.DeleteVehicle(worldVehicle)
                else
                    canGetVehicle = false
                end

                break
            end
        end

        count += 1
        vehicles[count] = {
            id = dbResult.id,
            plate = dbResult.plate,
            vehicle = dbResult.vehicle,
            stored = false
        }

        local vehicleName = ("%s %s"):format(modelData.make, modelData.name)
        local contextDescription = ("Plate: %s"):format(dbResult.plate)
        local contextMetadata = {
            { label = "Status", value = dbResult.impounded_at and (not canReleaseVehicle and ("Can be released in %s"):format(GetTimeStringFromSecond(dbResult.release_date_second_until)) or "Can be released now") or "Out" }
        }

        if dbResult.vehicle.plate ~= dbResult.plate then
            contextDescription = ("%s - %s"):format(contextDescription, ("Fake Plate: %s"):format(dbResult.vehicle.plate))
        end

        contextOptions[count] = {
            title = vehicleName,
            description = contextDescription,
            icon = GetIconForVehicleModel(dbResult.model, modelData.type),
            iconColor = not canReleaseVehicle and "red" or not canGetVehicle and "yellow" or "green",
            arrow = canReleaseVehicle and canGetVehicle,
            event = canReleaseVehicle and canGetVehicle and "esx_garage:openImpoundConfirmation",
            args = { vehicleName = vehicleName, vehicleType = modelData.type, vehicleId = dbResult.id, plate = dbResult.plate, impoundKey = impoundKey, releaseFee = dbResult.release_fee or Config.ImpoundPrice },
            metadata = contextMetadata,
            image = modelData.image
        }

        ::skipLoop::
    end

    return vehicles, contextOptions
end)

lib.callback.register("esx_garage:getGaragesThatAcceptVehicleType", function(_, vehicleType)
    ESX.Trace(vehicleType, nil, true)
    local garages = {}

    for garageKey in pairs(Config.Garages) do
        garages[garageKey] = DoesZoneAcceptVehicleType("garage", garageKey, vehicleType)
    end

    return garages
end)
