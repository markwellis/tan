ALTER TABLE `tan`.`tags` ADD COLUMN `stem` VARCHAR(30) NOT NULL  AFTER `tag` 
, ADD INDEX `tag` (`tag` ASC) 
, ADD INDEX `stem` (`stem` ASC) ;