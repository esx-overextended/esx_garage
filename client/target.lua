Target = {}

function Target.addVehicle(garageKey)
    local optionId = ("%s:store_vehicle"):format(cache.resource)

    exports["ox_target"]:addGlobalVehicle({
        {
            name = optionId,
            label = "Store Vehicle",
            icon = "fa-solid fa-parking",
            event = "esx_garages:storeOwnedVehicle",
            distance = 4,
            groups = Config.Garages[garageKey].Groups,
            canInteract = function()
                return IsPlayerAuthorizedToAccessGarage(garageKey)
            end,
            garageKey = garageKey
        }
    })

    return optionId
end

function Target.removeVehicle(data)
    return exports["ox_target"]:removeGlobalVehicle(data)
end

function Target.addPed(entity, data)
    local optionId = ("%s:open_%s"):format(cache.resource, data.garageKey and "garage" or data.impoundKey and "impound")

    exports["ox_target"]:addLocalEntity(entity, {
        {
            name = optionId,
            label = data.garageKey and "Open Garage" or data.impoundKey and "Open Impound",
            icon = data.garageKey and "fa-solid fa-warehouse" or data.impoundKey and "fa-solid fa-key",
            event = data.garageKey and "esx_garages:openGarageMenu" or data.impoundKey and "esx_garages:openImpoundMenu",
            distance = 4,
            groups = Config.Garages[data.garageKey]?.Groups,
            canInteract = function()
                return data.garageKey and IsPlayerAuthorizedToAccessGarage(data.garageKey) or data.impoundKey and true
            end,
            garageKey = data.garageKey,
            impoundKey = data.impoundKey
        }
    })

    return optionId
end

function Target.removePed(entity, optionId)
    return exports["ox_target"]:removeLocalEntity(entity, optionId)
end
