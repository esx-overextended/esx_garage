lib.callback.register("esx_garages:getOwnedVehicles", function(source, garageKey)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then return end

    if not IsPlayerInGarageZone(source, garageKey) then return --[[Player is cheating...]] end

    local vehicles, vehiclesCount = {}, 0
    local currentGarage = Config.Garages[garageKey]
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
        local vehicleName = ("%s %s"):format(modelData.make, modelData.name)

        contextOptions[vehiclesCount] = {
            title = vehicleName,
            arrow = vehicles[vehiclesCount].stored,
            event = vehicles[vehiclesCount].stored and "esx_garages:openVehicleMenu",
            args = { vehicleName = vehicleName, vehicleId = dbResult.id, plate = dbResult.plate, storedGarage = dbResult.garage, garageKey = garageKey },
            metadata = {
                ["Plate"] = dbResult.vehicle?.plate or dbResult.plate,
                ["Status"] = vehicles[vehiclesCount].stored and ("Stored in %s"):format(dbResult.garage == garageKey and "Here" or Config.Garages[dbResult.garage]?.Label) or "Out"
            }
        }

        ::skipLoop::
    end

    -- print(ESX.DumpTable(contextOptions))

    return vehicles, contextOptions
end)

lib.callback.register("esx_garages:transferVehicle", function(source, data)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer or type(data) ~= "table" then return end

    if not IsPlayerInGarageZone(source, data.garageKey) then return --[[Player is cheating...]] end

    if xPlayer.getMoney() < Config.TransferPrice then return xPlayer.showNotification(("You don't have $%s money in your pocket!"):format(Config.TransferPrice), "error") end

    xPlayer.removeMoney(Config.TransferPrice, ("Transferring of %s vehicle (%s) to %s"):format(data.vehicleName, data.plate, Config.Garages[data.garageKey].Label))

    return MySQL.update.await("UPDATE `owned_vehicles` SET `garage` = ? WHERE `id` = ? AND `owner` = ?", { data.garageKey, data.vehicleId, xPlayer.getIdentifier() })
end)