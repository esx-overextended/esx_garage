RegisterServerEvent("esx_garages:takeOutOwnedVehicle", function(data)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or type(data) ~= "table" then return end

    if not IsPlayerInGarageZone(source, data.garageKey) then return --[[Player is cheating...]] end

    local vehicleData = MySQL.single.await("SELECT `owner`, `stored`, `garage` FROM `owned_vehicles` WHERE `id` = ?", { data.vehicleId })

    if not vehicleData or vehicleData.owner ~= xPlayer.getIdentifier() or not vehicleData.stored or vehicleData.garage ~= data.garageKey then return print("cheating") --[[Player is cheating...]] end

    local spawnCoords = Config.Garages[data.garageKey].Spawns[data.spawnIndex]

    ESX.CreateVehicle(data.vehicleId, spawnCoords, spawnCoords.w)
end)
