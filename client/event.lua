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
                    for i = 1, #Config.Garages[data.garageKey].Spawns do
                        local spawnPoint = Config.Garages[data.garageKey].Spawns[i]

                        if ESX.Game.IsSpawnPointClear(vector3(spawnPoint.x, spawnPoint.y, spawnPoint.z), 1.0) then
                            data.spawnIndex = i
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