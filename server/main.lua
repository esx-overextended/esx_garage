local sql = {
    [[
        ALTER TABLE `owned_vehicles`
        ADD COLUMN IF NOT EXISTS `garage` VARCHAR(60) DEFAULT NULL,
        ADD COLUMN IF NOT EXISTS `last_garage` VARCHAR(60) DEFAULT 'legion',

        ADD INDEX IF NOT EXISTS `garage` (`garage`)
    ]],

    "DROP TRIGGER IF EXISTS `update_owned_vehicles_garage_and_last_garage`",
    [[
        CREATE TRIGGER `update_owned_vehicles_garage_and_last_garage`
        BEFORE UPDATE ON `owned_vehicles` FOR EACH ROW
        BEGIN
            IF NEW.stored = 0 OR NEW.stored IS NULL THEN
                SET NEW.garage = NULL;
            END IF;

            IF NEW.garage IS NOT NULL THEN
                SET NEW.last_garage = NEW.garage;
            END IF;
        END
    ]],

    [[
        CREATE TABLE IF NOT EXISTS `impounded_vehicles` (
            `id` INT NOT NULL,
            `reason` LONGTEXT NULL,
            `note` LONGTEXT NULL,
            `release_fee` INT NOT NULL,
            `release_date` timestamp NOT NULL,
            `impounded_by` VARCHAR(60) NULL,
            `impounded_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),

            UNIQUE INDEX `id` (`id`),
            CONSTRAINT `FK_impounded_vehicles_owned_vehicles` FOREIGN KEY (`id`) REFERENCES `owned_vehicles` (`id`) ON UPDATE CASCADE ON DELETE CASCADE
        )
    ]],
}

MySQL.ready(function()
    MySQL.transaction.await(sql)

    if Config.RestoreVehicles then
        MySQL.update.await("UPDATE `owned_vehicles` SET `stored` = 1, `garage` = `last_garage` WHERE `stored` != 1 AND NOT EXISTS (SELECT 1 FROM `impounded_vehicles` WHERE `impounded_vehicles`.`id` = `owned_vehicles`.`id`)")
    end
end)

---@param zoneType string
---@param zoneKey string
---@param vehicleType string
---@return boolean
function DoesZoneAcceptVehicleType(zoneType, zoneKey, vehicleType)
    local zoneData

    if zoneType == "garage" then
        zoneData = Config.Garages[zoneKey]
    elseif zoneType == "impound" then
        zoneData = Config.Impounds[zoneKey]
    end

    if not zoneData or type(vehicleType) ~= "string" then return false end

    local zoneAcceptedType = zoneData.Type

    if not zoneAcceptedType then return true end -- means this zone does not have a specific type, therefore all vehicles type are accepted

    local _type = type(zoneAcceptedType)

    if _type == "string" and zoneAcceptedType == vehicleType then
        return true
    elseif _type == "table" and table.type(zoneAcceptedType) == "array" then
        for i = 1, #zoneAcceptedType do
            if zoneAcceptedType[i] == vehicleType then
                return true
            end
        end
    end

    return false
end

---@param dbResults table
---@param garageKey string
---@return table, table
function GenerateVehicleDataAndContextFromQueryResult(dbResults, garageKey)
    local vehicles, contextOptions, count = {}, {}, 0

    if dbResults and garageKey then
        for i = 1, #dbResults do
            local dbResult = dbResults[i]
            dbResult.vehicle = json.decode(dbResult.vehicle)

            if (not dbResult.model or dbResult.model == "") and dbResult.vehicle?.model then -- probably just migrated from esx-legacy therefore dbResult.model is empty...
                for vModel, vData in pairs(ESX.GetVehicleData()) do
                    if vData.hash == dbResult.vehicle.model then
                        dbResult.model = vModel
                        break
                    end
                end
            end

            if (not dbResult.model or dbResult.model == "") then
                ESX.Trace(("Vehicle hash (^1%s^7) for Vehicle ID (^5%s^7) from database is invalid \nEnsure vehicle exists in ^2'@es_extended/files/vehicles.json'^7"):format(dbResult.vehicle?.model, dbResult.id), "warning", true)
                goto skipLoop
            end

            local modelData = ESX.GetVehicleData(dbResult.model)

            if not DoesZoneAcceptVehicleType("garage", garageKey, modelData?.type) then
                goto skipLoop
            end

            count += 1
            vehicles[count] = {
                id = dbResult.id,
                plate = dbResult.plate,
                vehicle = dbResult.vehicle,
                stored = dbResult.stored == 1,
                garage = dbResult.garage
            }

            local vehicleName = ("%s %s"):format(modelData.make, modelData.name)
            local contextDescription = ("Plate: %s"):format(dbResult.plate)
            local contextMetadata = {
                { label = "Status", value = vehicles[count].stored and ("Stored in %s"):format(dbResult.garage == garageKey and "Here" or Config.Garages[dbResult.garage]?.Label) or "Out" }
            }

            if dbResult.vehicle.plate ~= dbResult.plate then
                contextDescription = ("%s - %s"):format(contextDescription, ("Fake Plate: %s"):format(dbResult.vehicle.plate))
            end

            if vehicles[count].stored and dbResult.vehicle then
                if dbResult.vehicle.fuelLevel then
                    local fuelLevel = dbResult.vehicle.fuelLevel
                    contextMetadata[#contextMetadata + 1] = { label = "Fuel", value = ("%%%s"):format(fuelLevel), progress = fuelLevel }
                end

                if dbResult.vehicle.bodyHealth then
                    local bodyHealth = dbResult.vehicle.bodyHealth / 10
                    contextMetadata[#contextMetadata + 1] = { label = "Body Health", value = ("%%%s"):format(bodyHealth), progress = bodyHealth }
                end

                if dbResult.vehicle.engineHealth then
                    local engineHealth = dbResult.vehicle.engineHealth / 10
                    contextMetadata[#contextMetadata + 1] = { label = "Engine Health", value = ("%%%s"):format(engineHealth), progress = engineHealth }
                end
            end

            if dbResult.impounded_at then
                contextDescription = "Impounded"
            end

            contextOptions[count] = {
                title = vehicleName,
                description = contextDescription,
                icon = GetIconForVehicleModel(dbResult.model, modelData.type),
                iconColor = dbResult.impounded_at and "red" or not vehicles[count].stored and "yellow" or vehicles[count].garage ~= garageKey and "DodgerBlue" or "green",
                arrow = vehicles[count].stored,
                disabled = dbResult.impounded_at ~= nil,
                event = vehicles[count].stored and "esx_garage:openVehicleMenu",
                args = { vehicleName = vehicleName, vehicleId = dbResult.id, plate = dbResult.plate, storedGarage = dbResult.garage, garageKey = garageKey },
                metadata = contextMetadata,
                image = modelData.image
            }

            ::skipLoop::
        end
    end

    return vehicles, contextOptions
end

---@param xPlayer table | number
---@param groupsToCheck? string | table
---@return boolean
function DoesPlayerHaveAccessToGroup(xPlayer, groupsToCheck)
    if not groupsToCheck or groupsToCheck == "" then return true end

    local xPlayerType = type(xPlayer)

    if xPlayerType == "number" then
        xPlayer = ESX.GetPlayerFromId(xPlayer)
        xPlayerType = "table"
    end

    if xPlayerType ~= "table" then return false end

    return xPlayer.canInteractWithGroup and xPlayer.canInteractWithGroup(groupsToCheck)
end

---@param xPlayer table
---@param garageKey string
---@return boolean
function IsPlayerAuthorizedToAccessGarage(xPlayer, garageKey)
    local groupsToCheck = Config.Garages[garageKey]?.Groups

    return DoesPlayerHaveAccessToGroup(xPlayer, groupsToCheck)
end

---@param coords vector3 | vector4 | table
---@param range? number
---@return boolean
function IsCoordsAvailableToSpawn(coords, range)
    coords = vector3(coords.x, coords.y, coords.z)
    range = range or 2.25

    local _, _, count = ESX.OneSync.GetVehiclesInArea(coords, range)

    return count == 0
end

function ApplyFuelToVehicle(vehicleEntity, fuelAmount)
    if not vehicleEntity or not fuelAmount then return end

    if GetResourceState("ox_fuel"):find("start") then
        return Entity(vehicleEntity).state:set("fuel", fuelAmount, true)
    end
end

---@param source string | number
function CheatDetected(source)
    print(("[^1CHEATING^7] Player (^5%s^7) with the identifier of (^5%s^7) is detected ^1cheating^7!"):format(source, GetPlayerIdentifierByType(source --[[@as string]], "license")))
end

---@param secondsToConvert number
---@return string
function GetTimeStringFromSecond(secondsToConvert)
    local hours = math.floor(secondsToConvert / 3600)
    local minutes = math.floor((secondsToConvert % 3600) / 60)
    local seconds = secondsToConvert % 60

    hours = hours < 10 and ("0%s"):format(hours) or tostring(hours) ---@diagnostic disable-line: cast-local-type
    minutes = minutes < 10 and ("0%s"):format(minutes) or tostring(minutes) ---@diagnostic disable-line: cast-local-type
    seconds = seconds < 10 and ("0%s"):format(seconds) or tostring(seconds) ---@diagnostic disable-line: cast-local-type

    return ("%s:%s:%s"):format(hours, minutes, seconds)
end

---@param vehicleModel string
---@return string
function GetIconForVehicleModel(vehicleModel, modelType)
    modelType = modelType or ESX.GetVehicleData(vehicleModel)?.type

    if modelType == "automobile" then
        return "fa-solid fa-car"
    elseif modelType == "bike" then
        return "fa-solid fa-motorcycle"
    elseif modelType == "quadbike" then
        return "fa-solid fa-tricycle-adult"
    elseif modelType == "bicycle" then
        return "fa-solid fa-bicycle"
    elseif modelType == "heli" then
        return "fa-solid fa-helicopter"
    elseif modelType == "plane" then
        return "fa-solid fa-plane"
    elseif modelType == "trailer" then
        return "fa-solid fa-trailer"
    elseif modelType == "boat" then
        return "fa-solid fa-sailboat"
    end

    return "fa-solid fa-car" -- default icon
end

---@class CImpoundData
---@field entity number
---@field reason? string
---@field note? string
---@field releaseFee? number
---@field releaseDate? osdate
---@field impoundedBy? string

---Deletes the vehicle entity and impounds it with the specified data if it's an owned vehicle
---@param data CImpoundData
---@return boolean, string
function ImpoundVehicle(data)
    if type(data) ~= "table" or type(data?.entity) ~= "number" then return false, "invalid_data" end

    if not DoesEntityExist(data.entity) then return false, "invalid_entity" end

    local xVehicle = ESX.GetVehicle(data.entity)

    if xVehicle and xVehicle.id then -- owned vehicle
        local impounded_at = MySQL.scalar.await("SELECT `impounded_at` FROM `impounded_vehicles` WHERE `id` = ?", { xVehicle.id })

        if impounded_at then return false, "already_impounded" end

        MySQL.insert.await("INSERT INTO `impounded_vehicles` VALUES (?, ?, ?, ?, ?, ?)", { xVehicle.id, data.reason, data.note, data.releaseFee or Config.ImpoundPrice, data.releaseDate, data.impoundedBy })
    end

    ESX.DeleteVehicle(data.entity)

    return true, "successful"
end

exports("ImpoundVehicle", ImpoundVehicle)
