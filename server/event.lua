RegisterServerEvent("esx_garages:takeOutOwnedVehicle", function(data)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or type(data) ~= "table" then return end

    if not IsPlayerInGarageZone(xPlayer.source, data.garageKey) or not IsPlayerAuthorizedToAccessGarage(xPlayer, data.garageKey) then return CheatDetected(xPlayer.source) end

    local vehicleData = MySQL.single.await("SELECT `owner`, `stored`, `garage`, `vehicle` FROM `owned_vehicles` WHERE `id` = ?", { data.vehicleId })

    if not vehicleData or (not Config.Garages[data.garageKey].Groups and vehicleData.owner ~= xPlayer.getIdentifier()) or not vehicleData.stored or vehicleData.garage ~= data.garageKey then return CheatDetected(xPlayer.source) end

    local spawnCoords = Config.Garages[data.garageKey].Spawns[data.spawnIndex]

    if not spawnCoords and Shared.AvailableSpawnPointIndicator == lib.context then
        local spawnPoints = {}

        for i = 1, #Config.Garages[data.garageKey].Spawns do
            local spawnPoint = Config.Garages[data.garageKey].Spawns[i]
            spawnPoints[i] = { x = spawnPoint.x, y = spawnPoint.y, z = spawnPoint.z, index = i }
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

    local xVehicle = ESX.CreateVehicle(data.vehicleId, spawnCoords, spawnCoords.w)

    if not xVehicle then return end

    xPlayer.showNotification("Vehicle spawned!", "success")

    vehicleData.vehicle = vehicleData.vehicle and json.decode(vehicleData.vehicle)

    ApplyFuelToVehicle(xVehicle.entity, vehicleData.vehicle?.fuelLevel)
end)

RegisterServerEvent("esx_garages:storeOwnedVehicle", function(data)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or type(data) ~= "table" then return end

    local entity = NetworkGetEntityFromNetworkId(data.netId)
    local xVehicle = ESX.GetVehicle(entity)

    if not xVehicle or (xVehicle.owner ~= xPlayer.getIdentifier() and xVehicle.group ~= xPlayer.getJob()?.name and not xPlayer.hasGroup(xVehicle.group)) then return xPlayer.showNotification("You cannot store this vehicle!", "error") end

    local currentGarageGroups = Config.Garages[data.garageKey].Groups

    if currentGarageGroups or xVehicle.group then
        local canStoreVehicleHere = false
        local _type = type(currentGarageGroups)

        if _type == "string" then
            canStoreVehicleHere = xVehicle.group == currentGarageGroups
        elseif _type == "table" then
            if table.type(Config.Garages[data.garageKey].Groups) == "array" then
                for i = 1, #Config.Garages[data.garageKey].Groups do
                    if xVehicle.group == Config.Garages[data.garageKey].Groups[i] then
                        canStoreVehicleHere = true
                        break
                    end
                end
            else
                for groupName in pairs(Config.Garages[data.garageKey].Groups) do
                    if xVehicle.group == groupName then
                        canStoreVehicleHere = true
                        break
                    end
                end
            end
        end

        if not canStoreVehicleHere then return xPlayer.showNotification("You cannot store this vehicle here in this garage!", "error") end
    end

    if not IsCoordsInGarageZone(xVehicle.getCoords(true), data.garageKey) or not IsPlayerAuthorizedToAccessGarage(xPlayer, data.garageKey) or GetEntityModel(entity) ~= data.properties?.model then return CheatDetected(xPlayer.source) end

    xVehicle.setStored(true, true)

    MySQL.update.await("UPDATE `owned_vehicles` SET `vehicle` = ?, `garage` = ? WHERE `id` = ?", { json.encode(data.properties), data.garageKey, xVehicle.id })

    xPlayer.showNotification("Vehicle stored!", "success")
end)
