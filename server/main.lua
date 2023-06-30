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