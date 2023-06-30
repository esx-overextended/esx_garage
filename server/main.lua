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
