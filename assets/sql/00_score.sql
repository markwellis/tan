ALTER TABLE `tan`.`object` ADD COLUMN `score` BIGINT(20) NULL DEFAULT NULL  AFTER `deleted` 
, DROP INDEX `created` 
, ADD INDEX `created` (`created` ASC, `views` ASC, `plus` ASC, `minus` ASC, `comments` ASC, `score` ASC) 
, DROP INDEX `promoted` 
, ADD INDEX `promoted` (`promoted` ASC, `minus` ASC, `plus` ASC, `comments` ASC, `score` ASC, `views` ASC) ;