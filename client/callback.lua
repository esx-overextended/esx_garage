lib.callback.register("esx_garage:getVehicleImage", function(vehicleNetId)
    return exports["es_extended"]:generateVehicleImage(NetworkGetEntityFromNetworkId(vehicleNetId))
end)
