ESX.RegisterClientCallback("esx_garage:getVehicleProperties", function(cb, vehicleNetId)
    cb(ESX.Game.GetVehicleProperties(NetworkGetEntityFromNetworkId(vehicleNetId)))
end)
