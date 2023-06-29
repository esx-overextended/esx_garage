AddEventHandler("esx_garages:storeVehicle", function(target)

end)

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
                serverEvent = "esx_garages:spawnVehicle",
                args = data,
                arrow = canTakeoutVehicle,
                disabled = not canTakeoutVehicle
            },
        }
    })

    return lib.showContext("esx_garages:vehicleMenu")
end)