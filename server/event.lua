RegisterServerEvent("esx_garages:takeOutOwnedVehicle", function(data)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or type(data) ~= "table" then return end

    if not IsPlayerInGarageZone(xPlayer.source, data.garageKey) then return --[[Player is cheating...]] end

    local vehicleData = MySQL.single.await("SELECT `owner`, `stored`, `garage` FROM `owned_vehicles` WHERE `id` = ?", { data.vehicleId })

    if not vehicleData or vehicleData.owner ~= xPlayer.getIdentifier() or not vehicleData.stored or vehicleData.garage ~= data.garageKey then return --[[Player is cheating...]] end

    local spawnCoords = Config.Garages[data.garageKey].Spawns[data.spawnIndex]

    ESX.CreateVehicle(data.vehicleId, spawnCoords, spawnCoords.w)

    xPlayer.showNotification("Vehicle spawned", "success")
end)

RegisterServerEvent("esx_garages:storeOwnedVehicle", function(data)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    local entity = NetworkGetEntityFromNetworkId(data?.entity)
    local xVehicle = ESX.GetVehicle(entity)

    if not xVehicle or xVehicle.owner ~= xPlayer.getIdentifier() then return xPlayer.showNotification("You cannot store this vehicle", "error") end

    if not IsCoordsInGarageZone(xVehicle.getCoords(true), data.garageKey) then return --[[Player is cheating...]] end

    xVehicle.setStored(true, true)

    MySQL.update.await("UPDATE `owned_vehicles` SET `garage` = ? WHERE `id` = ?", { data.garageKey, xVehicle.id })

    xPlayer.showNotification("Vehicle stored", "success")
end)