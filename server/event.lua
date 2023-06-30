RegisterServerEvent("esx_garages:takeOutOwnedVehicle", function(data)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or type(data) ~= "table" then return end

    if not IsPlayerInGarageZone(xPlayer.source, data.garageKey) or not IsPlayerAuthorizedToAccessGarage(xPlayer, data.garageKey) then return CheatDetected(xPlayer.source) end

    local vehicleData = MySQL.single.await("SELECT `owner`, `stored`, `garage` FROM `owned_vehicles` WHERE `id` = ?", { data.vehicleId })

    if not vehicleData or vehicleData.owner ~= xPlayer.getIdentifier() or not vehicleData.stored or vehicleData.garage ~= data.garageKey then return CheatDetected(xPlayer.source) end

    local spawnCoords = Config.Garages[data.garageKey].Spawns[data.spawnIndex]

    if not spawnCoords then
        local spawnPoints = {}

        for i = 1, #Config.Garages[data.garageKey].Spawns do
            local spawnPoint = Config.Garages[data.garageKey].Spawns[i]
            spawnPoints[i] = { x = spawnPoint.z, y = spawnPoint.y, z = spawnPoint.z, index = i}
        end

        local coords = GetEntityCoords(GetPlayerPed(xPlayer.source))

        table.sort(spawnPoints, function(a, b)
            return #(vector3(a.x, a.y, a.z) - coords) < #(vector3(b.x, b.y, b.z) - coords)
        end)

        for i = 1, #spawnPoints do
            local spawnPoint = spawnPoints[i]

            if IsCoordsAvailableToSpawn(spawnPoint) then
                spawnCoords = Config.Garages[data.garageKey].Spawns[spawnPoint.index]
                break
            end
        end
    end

    if not spawnCoords then return xPlayer.showNotification("None of the spawn points are clear at the moment!") end

    ESX.CreateVehicle(data.vehicleId, spawnCoords, spawnCoords.w)

    xPlayer.showNotification("Vehicle spawned", "success")
end)

RegisterServerEvent("esx_garages:storeOwnedVehicle", function(data)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or type(data) ~= "table" then return end

    local entity = NetworkGetEntityFromNetworkId(data.netId)
    local xVehicle = ESX.GetVehicle(entity)

    if not xVehicle or xVehicle.owner ~= xPlayer.getIdentifier() then return xPlayer.showNotification("You cannot store this vehicle", "error") end

    if not IsCoordsInGarageZone(xVehicle.getCoords(true), data.garageKey) or not IsPlayerAuthorizedToAccessGarage(xPlayer, data.garageKey) or GetEntityModel(entity) ~= data.properties?.model then return CheatDetected(xPlayer.source) end

    xVehicle.setStored(true, true)

    MySQL.update.await("UPDATE `owned_vehicles` SET `vehicle` = ?, `garage` = ? WHERE `id` = ?", { json.encode(data.properties), data.garageKey, xVehicle.id })

    xPlayer.showNotification("Vehicle stored", "success")
end)
