MySQL.ready(function()
    MySQL.update.await([[ALTER TABLE `owned_vehicles`
    ADD COLUMN IF NOT EXISTS `garage` VARCHAR(60) DEFAULT NULL,
    ADD COLUMN IF NOT EXISTS `last_garage` VARCHAR(60) DEFAULT 'legion']])

    if Config.RestoreVehicles then
        MySQL.update.await("UPDATE `owned_vehicles` SET `stored` = 1, `garage` = `last_garage` WHERE `stored` = 0 OR `stored` IS NULL")
    end
end)
