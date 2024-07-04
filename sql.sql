ALTER TABLE `player_vehicles` ADD `vparking` TINYINT(1) NOT NULL DEFAULT '0' AFTER `state`;
ALTER TABLE `player_vehicles` ADD `parking_coord` LONGTEXT AFTER `vparking`;
ALTER TABLE `player_vehicles` ADD `vtowing_repaired` TINYINT(1) NOT NULL DEFAULT '0' AFTER `parking_coord`;
