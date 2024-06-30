-- This will be modified or even moved to another resource for a more complex functionality in future
ESX.RegisterCommand("assignvehicle", "admin", function(xPlayer, args, _)
    local properties
    local isSuccessul = false
    local playerPed = GetPlayerPed(xPlayer.source)
    local vehicleEntity = GetVehiclePedIsIn(playerPed, false)

    if vehicleEntity ~= 0 then
        local xVehicle = ESX.GetVehicle(vehicleEntity)

        if not xVehicle or xVehicle?.group --[[to make sure not to override the current vehicle's group]] then
            return xPlayer.showNotification("This vehicle cannot be assigned to the specified group/job. Get out of it and spawn a new vehicle!", "error")
        end

        if xVehicle.id then -- if vehicle is registered in database
            isSuccessul = true

            xVehicle.setGroup(args.group)
        else
            args.vehicle = xVehicle.model
            properties = ESX.TriggerClientCallback(xPlayer.source, "esx_garage:getVehicleProperties", xVehicle.netId)

            ESX.DeleteVehicle(vehicleEntity)
        end
    end

    if not isSuccessul then
        local coords = xPlayer.getCoords()
        local xVehicle = ESX.CreateVehicle({
            model = args.vehicle,
            group = args.group,
            properties = properties
        }, coords, coords.heading)

        if not xVehicle then
            return xPlayer.showNotification("The specified vehicle could not be generated!", "error")
        end

        for _ = 1, 50 do
            Wait(0)
            SetPedIntoVehicle(playerPed, xVehicle.entity, -1)

            if GetVehiclePedIsIn(playerPed, false) == xVehicle.entity then
                break
            end
        end
    end

    xPlayer.showNotification("The vehicle is successfully assigned to the specified group!", "success")
end, false, {
    help = "Admins way of assigning a vehicle to a group/job",
    validate = false,
    arguments = {
        { name = "group",   help = "name of the group/job that the vehicle should be assigned to",                type = "string" },
        { name = "vehicle", help = "vehicle name/model to assign (only if you are not already inside a vehicle)", type = "string" }
    }
})
