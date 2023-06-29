lib.callback.register("esx_garages:getOwnedVehicles", function(source, garageIndex)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    if not IsPlayerInGarageZone(source, garageIndex) then return --[[Player is cheating...]] end

    local vehicles, vehiclesCount = {}, 0
    local currentGarage = Config.Garages[garageIndex]
    local contextOptions = {}

    local dbResults = MySQL.rawExecute.await("SELECT `id`, `plate`, `vehicle`, `model`, `stored`, `garage` FROM `owned_vehicles` WHERE `owner` = ? AND `type` = ? AND `job` IS NULL", { xPlayer.getIdentifier(), currentGarage.Type })

    for i = 1, #dbResults do
        local dbResult = dbResults[i]
        dbResult.vehicle = json.decode(dbResult.vehicle)

        if not dbResult.model and dbResult.vehicle?.model then -- probably just migrated from esx-legacy therefore dbResult.model is empty...
            for vModel, vData in pairs(ESX.GetVehicleData()) do
                if vData.hash == dbResult.vehicle.model then
                    dbResult.model = vModel
                    break
                end
            end
        end

        if not dbResult.model then print(("[^3WARNING^7] Vehicle hash (^1%s^7) is invalid \nEnsure vehicle exists in ^2'@es_extended/files/vehicles.json'^7"):format(dbResult.vehicle?.model)) goto skipLoop end

        vehiclesCount += 1
        vehicles[vehiclesCount] = {
            id = dbResult.id,
            plate = dbResult.plate,
            vehicle = dbResult.vehicle,
            stored = dbResult.stored == 1,
            garage = dbResult.garage
        }

        local modelData = ESX.GetVehicleData(dbResult.model)
        local vehicleGarageStatus

        if not dbResult.garage then
            vehicleGarageStatus = "Out"
        elseif dbResult.garage == currentGarage.Name then
            vehicleGarageStatus = "Stored Here"
        elseif dbResult.garage ~= currentGarage.Name then
            for j = 1, #Config.Garages do
                if Config.Garages[j].Name == dbResult.garage then
                    vehicleGarageStatus = ("Stored in %s"):format(Config.Garages[j].Label)
                    break
                end
            end
        end

        contextOptions[vehiclesCount] = {
            title = ("%s %s"):format(modelData.make, modelData.name),
            event = vehicles[vehiclesCount].stored and "TODO" or nil,
            arrow = vehicles[vehiclesCount].stored,
            metadata = {
                ["Plate"] = dbResult.vehicle?.plate or dbResult.plate,
                ["Status"] = vehicleGarageStatus
            }
        }

        ::skipLoop::
    end

    print(ESX.DumpTable(contextOptions))

    return vehicles, contextOptions
end)
