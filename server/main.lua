local sql = {
    [[
        ALTER TABLE `owned_vehicles`
        ADD COLUMN IF NOT EXISTS `garage` VARCHAR(60) DEFAULT NULL,
        ADD COLUMN IF NOT EXISTS `last_garage` VARCHAR(60) DEFAULT 'legion'
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
            `release_fee` INT NULL,
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
        MySQL.update.await("UPDATE `owned_vehicles` SET `stored` = 1, `garage` = `last_garage` WHERE `stored` = 0 OR `stored` IS NULL")
    end
end)

---@param xPlayer table | number
---@param garageKey string
---@return boolean
function IsPlayerAuthorizedToAccessGarage(xPlayer, garageKey)
    local garageGroups = Config.Garages[garageKey].Groups

    if not garageGroups then return true end

    local garageGroupsType = type(garageGroups)

    if garageGroupsType == "string" then
        garageGroups = { garageGroups }
        garageGroupsType = "table"
    end

    local xPlayerType = type(xPlayer)

    if xPlayerType == "number" then
        xPlayer = ESX.GetPlayerFromId(xPlayer)
        xPlayerType = "table"
    end

    if xPlayerType ~= "table" then return false end

    xPlayer.job = xPlayer.getJob()
    local playerGroups = xPlayer.getGroups()
    local playerJobName = xPlayer.job.name
    local playerJobDuty = xPlayer.job.duty
    local playerJobGrade = xPlayer.job.grade

    if garageGroupsType == "table" then
        if table.type(garageGroups) == "array" then
            for i = 1, #garageGroups do
                local garageGroupName = garageGroups[i]

                if garageGroupName == playerJobName and playerJobDuty then return true end

                if playerGroups[garageGroupName] and not ESX.GetJob(garageGroupName) --[[making sure the group is not a job]] then return true end
            end
        else
            for garageGroupName, garageGroupGrade in pairs(garageGroups) do
                if garageGroupName == playerJobName and garageGroupGrade == playerJobGrade and playerJobDuty then return true end

                if playerGroups[garageGroupName] == garageGroupGrade and not ESX.GetJob(garageGroupName) --[[making sure the group is not a job]] then return true end
            end
        end
    end

    return false
end

---@param coords vector3 | vector4 | table
---@param range? number
---@return boolean
function IsCoordsAvailableToSpawn(coords, range)
    coords = vector3(coords.x, coords.y, coords.z)
    range = range or 3.0

    local _, _, vehiclesCount = ESX.OneSync.GetVehiclesInArea(coords, range)

    return vehiclesCount == 0
end

---@param source string | number
function CheatDetected(source)
    print(("[^1CHEATING^7] Player (^5%s^7) with the identifier of (^5%s^7) is detected ^1cheating^7 through triggering events!"):format(source, GetPlayerIdentifierByType(source --[[@as string]], "license")))
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

        MySQL.insert.await("INSERT INTO `impounded_vehicles` VALUES (?, ?, ?, ?, ?, ?)", { xVehicle.id, data.reason, data.note, data.releaseFee, data.releaseDate, data.impoundedBy })
    end

    ESX.DeleteVehicle(data.entity)

    return true, "successful"
end

exports("ImpoundVehicle", ImpoundVehicle)