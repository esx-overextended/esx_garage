Target = {}

function Target.addVehicle(garageKey)
    local optionId = ("%s:store_vehicle"):format(cache.resource)

    exports["ox_target"]:addGlobalVehicle({
        {
            name = optionId,
            label = "Store Vehicle",
            icon = "fa-solid fa-parking",
            event = "esx_garages:storeOwnedVehicle",
            distance = 3,
            garageKey = garageKey
        }
    })

    return optionId
end

function Target.removeVehicle(data)
    return exports["ox_target"]:removeGlobalVehicle(data)
end

function Target.addPed(entity, garageKey)
    local optionId = ("%s:open_garage"):format(cache.resource)

    exports["ox_target"]:addLocalEntity(entity, {
        {
            name = optionId,
            label = "Open Garage",
            icon = "fa-solid fa-warehouse",
            event = "esx_garages:openGarageMenu",
            distance = 3,
            garageKey = garageKey
        }
    })

    return optionId
end

function Target.removePed(entity, optionId)
    return exports["ox_target"]:removeLocalEntity(entity, optionId)
end
