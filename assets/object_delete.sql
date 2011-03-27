ALTER TABLE `tan`.`object` ADD COLUMN `deleted` ENUM('Y','N') NOT NULL DEFAULT 'N'  AFTER `comments` 
, DROP INDEX `super_index` 
, ADD INDEX `super_index` (`NSFW` ASC, `type` ASC, `promoted` ASC, `created` ASC, `deleted` ASC) ;