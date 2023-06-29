AddEventHandler("esx_garages:storeVehicle", function(target)

end)

AddEventHandler("esx_garages:openGarageMenu", function(target)
    local vehicles, contextOptions = lib.callback.await("esx_garages:getOwnedVehicles", false, target?.garageIndex)

    lib.registerContext({
        id = "esx_garages:garageMenu",
        title = Config.Garages[target?.garageIndex]?.Label,
        options = vehicles and contextOptions
    })

    return lib.showContext("esx_garages:garageMenu")
end)
