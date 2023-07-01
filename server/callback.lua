lib.callback.register("esx_garages:getOwnedVehicles", function(source, garageKey)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    if not IsPlayerInGarageZone(xPlayer.source, garageKey) or not IsPlayerAuthorizedToAccessGarage(xPlayer, garageKey) then return CheatDetected(xPlayer.source) end

    local query = "SELECT ov.`id`, ov.`plate`, ov.`vehicle`, ov.`model`, ov.`stored`, ov.`garage` FROM `owned_vehicles` AS ov LEFT JOIN `impounded_vehicles` AS iv ON ov.`id` = iv.`id` WHERE ov.`owner` = ? AND ov.`type` = ? AND ov.`job` IS NULL"
    local dbResults = MySQL.rawExecute.await(query, { xPlayer.getIdentifier(), Config.Garages[garageKey].Type })

    return GenerateVehicleDataAndContextFromQueryResult(dbResults, garageKey)
end)

lib.callback.register("esx_garages:getSocietyVehicles", function(source, garageKey)
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

    local query =
    "SELECT ov.`id`, ov.`plate`, ov.`vehicle`, ov.`model`, ov.`stored`, ov.`garage` FROM `owned_vehicles` AS ov LEFT JOIN `impounded_vehicles` AS iv ON ov.`id` = iv.`id` WHERE (ov.`owner` = ? OR ov.`owner` IS NULL) AND ov.`type` = ? AND ov.`job` IN (?)"
    local dbResults = MySQL.rawExecute.await(query, { xPlayer.getIdentifier(), Config.Garages[garageKey].Type, table.unpack(currentGarageGroups) })

    return GenerateVehicleDataAndContextFromQueryResult(dbResults, garageKey)
end)

lib.callback.register("esx_garages:transferVehicle", function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or type(data) ~= "table" then return end

    if not IsPlayerInGarageZone(xPlayer.source, data.garageKey) or not IsPlayerAuthorizedToAccessGarage(xPlayer, data.garageKey) then return CheatDetected(xPlayer.source) end

    if xPlayer.getMoney() < Config.TransferPrice then return xPlayer.showNotification(("You don't have $%s money in your pocket!"):format(Config.TransferPrice), "error") end

    xPlayer.removeMoney(Config.TransferPrice, ("Transferring of %s vehicle (%s) to %s"):format(data.vehicleName, data.plate, Config.Garages[data.garageKey].Label))

    return MySQL.update.await("UPDATE `owned_vehicles` SET `garage` = ? WHERE `id` = ? AND `owner` = ?", { data.garageKey, data.vehicleId, xPlayer.getIdentifier() })
end)
