AddEventHandler("esx_garages:openGarageMenu", function(data)
    if not IsPlayerInGarageZone(data?.garageKey) then return end

    local vehicles, contextOptions = lib.callback.await("esx_garages:getOwnedVehicles", false, data.garageKey)

    lib.registerContext({
        id = "esx_garages:garageMenu",
        title = Config.Garages[data.garageKey]?.Label,
        options = vehicles and contextOptions
    })

    return lib.showContext("esx_garages:garageMenu")
end)

AddEventHandler("esx_garages:openVehicleMenu", function(data)
    if not IsPlayerInGarageZone(data?.garageKey) then return end

    local canTakeoutVehicle = data.storedGarage == data.garageKey

    lib.registerContext({
        id = "esx_garages:vehicleMenu",
        title = data.vehicleName,
        menu = "esx_garages:garageMenu",
        options = {
            {
                title = "Transfer vehicle to this garage",
                event = "esx_garages:openGarageMenu",
                args = data,
                arrow = not canTakeoutVehicle,
                disabled = canTakeoutVehicle,
                onSelect = function()
                    lib.callback.await("esx_garages:transferVehicle", false, data)
                end
            },
            {
                title = "Take out vehicle",
                arrow = canTakeoutVehicle,
                disabled = not canTakeoutVehicle,
                onSelect = function()
                    local spawnPoints = {}

                    for i = 1, #Config.Garages[data.garageKey].Spawns do
                        local spawnPoint = Config.Garages[data.garageKey].Spawns[i]
                        spawnPoints[i] = { x = spawnPoint.z, y = spawnPoint.y, z = spawnPoint.z, index = i}
                    end

                    table.sort(spawnPoints, function(a, b)
                        return #(vector3(a.x, a.y, a.z) - cache.coords) < #(vector3(b.x, b.y, b.z) - cache.coords)
                    end)

                    for i = 1, #spawnPoints do
                        local spawnPoint = spawnPoints[i]

                        if ESX.Game.IsSpawnPointClear(vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z), 2.0) then
                            data.spawnIndex = spawnPoint.index
                            return TriggerServerEvent("esx_garages:takeOutOwnedVehicle", data)
                        end
                    end

                    ESX.ShowNotification("None of the spawn points are clear at the moment!")
                end
            },
        }
    })

    return lib.showContext("esx_garages:vehicleMenu")
end)

AddEventHandler("esx_garages:storeOwnedVehicle", function(data)
    if not IsCoordsInGarageZone(GetEntityCoords(data?.entity), data?.garageKey) then return end

    data.netId = NetworkGetNetworkIdFromEntity(data.entity)
    data.properties = ESX.Game.GetVehicleProperties(data.entity)

    TriggerServerEvent("esx_garages:storeOwnedVehicle", data)
end)