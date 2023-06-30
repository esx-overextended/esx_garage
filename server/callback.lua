lib.callback.register("esx_garages:getOwnedVehicles", function(source, garageKey)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    if not IsPlayerInGarageZone(xPlayer.source, garageKey) or not IsPlayerAuthorizedToAccessGarage(xPlayer, garageKey) then return CheatDetected(xPlayer.source) end

    local vehicles, vehiclesCount = {}, 0
    local currentGarage = Config.Garages[garageKey]
    local contextOptions = {}

    local dbResults = MySQL.rawExecute.await("SELECT ov.`id`, ov.`plate`, ov.`vehicle`, ov.`model`, ov.`stored`, ov.`garage` FROM `owned_vehicles` AS ov LEFT JOIN `impounded_vehicles` AS iv ON ov.`id` = iv.`id` WHERE ov.`owner` = ? AND ov.`type` = ? AND ov.`job` IS NULL", { xPlayer.getIdentifier(), currentGarage.Type })

    for i = 1, #dbResults do
        local dbResult = dbResults[i]
        dbResult.vehicle = json.decode(dbResult.vehicle)

        if not dbResult.model and dbResult.vehicle?.model then -- probably just migrated from esx-legacy therefore dbResult.model is empty...
            for vModel, vData in pairs(ESX.GetVehicleData()) do
                if vData.hash == dbResult.vehicle.model then
                    dbResult.model = vModel
                    break
                end
            end
        end

        if not dbResult.model then print(("[^3WARNING^7] Vehicle hash (^1%s^7) for ID (^5%s^7) is invalid \nEnsure vehicle exists in ^2'@es_extended/files/vehicles.json'^7"):format(dbResult.vehicle?.model, dbResult.id)) goto skipLoop end

        vehiclesCount += 1
        vehicles[vehiclesCount] = {
            id = dbResult.id,
            plate = dbResult.plate,
            vehicle = dbResult.vehicle,
            stored = dbResult.stored == 1,
            garage = dbResult.garage
        }

        local modelData = ESX.GetVehicleData(dbResult.model)
        local vehicleName = ("%s %s"):format(modelData.make, modelData.name)

        local contextDescription = ("Plate: %s"):format(dbResult.plate)
        local contextMetadata = {
            { label = "Status", value = vehicles[vehiclesCount].stored and ("Stored in %s"):format(dbResult.garage == garageKey and "Here" or Config.Garages[dbResult.garage]?.Label) or "Out" }
        }

        if dbResult.vehicle.plate ~= dbResult.plate then
            contextDescription = ("%s - %s"):format(contextDescription, ("Fake Plate: %s"):format(dbResult.vehicle.plate))
        end

        if vehicles[vehiclesCount].stored and dbResult.vehicle then
            if dbResult.vehicle.fuelLevel then
                local fuelLevel = dbResult.vehicle.fuelLevel
                contextMetadata[#contextMetadata + 1] = { label = "Fuel", value = ("%%%s"):format(fuelLevel), progress = fuelLevel }
            end

            if dbResult.vehicle.bodyHealth then
                local bodyHealth = dbResult.vehicle.bodyHealth / 10
                contextMetadata[#contextMetadata + 1] = { label = "Body Health", value = ("%%%s"):format(bodyHealth), progress = bodyHealth }
            end

            if dbResult.vehicle.engineHealth then
                local engineHealth = dbResult.vehicle.engineHealth / 10
                contextMetadata[#contextMetadata + 1] = { label = "Engine Health", value = ("%%%s"):format(engineHealth), progress = engineHealth }
            end
        end

        if dbResult.impounded_at then
            contextDescription = "Impounded"
        end

        contextOptions[vehiclesCount] = {
            title = vehicleName,
            description = contextDescription,
            arrow = vehicles[vehiclesCount].stored,
            disabled = dbResult.impounded_at ~= nil,
            event = vehicles[vehiclesCount].stored and "esx_garages:openVehicleMenu",
            args = { vehicleName = vehicleName, vehicleId = dbResult.id, plate = dbResult.plate, storedGarage = dbResult.garage, garageKey = garageKey },
            metadata = contextMetadata
        }

        ::skipLoop::
    end

    -- print(ESX.DumpTable(contextOptions))

    return vehicles, contextOptions
end)

lib.callback.register("esx_garages:transferVehicle", function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or type(data) ~= "table" then return end

    if not IsPlayerInGarageZone(xPlayer.source, data.garageKey) or not IsPlayerAuthorizedToAccessGarage(xPlayer, data.garageKey) then return CheatDetected(xPlayer.source) end

    if xPlayer.getMoney() < Config.TransferPrice then return xPlayer.showNotification(("You don't have $%s money in your pocket!"):format(Config.TransferPrice), "error") end

    xPlayer.removeMoney(Config.TransferPrice, ("Transferring of %s vehicle (%s) to %s"):format(data.vehicleName, data.plate, Config.Garages[data.garageKey].Label))

    return MySQL.update.await("UPDATE `owned_vehicles` SET `garage` = ? WHERE `id` = ? AND `owner` = ?", { data.garageKey, data.vehicleId, xPlayer.getIdentifier() })
end)