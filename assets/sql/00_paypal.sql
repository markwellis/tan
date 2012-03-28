SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

ALTER TABLE `tan`.`user` ADD COLUMN `paypal` VARCHAR(255) NOT NULL  AFTER `deleted` ;

CREATE  TABLE IF NOT EXISTS `tan`.`lotto` (
  `lotto_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `created` TIMESTAMP NOT NULL DEFAULT NOW() ,
  `user_id` BIGINT(20) NOT NULL ,
  `number` TINYINT(4) NOT NULL ,
  `confirmed` ENUM('Y','N') NOT NULL DEFAULT 'N' ,
  `winner` ENUM('y','n') NOT NULL DEFAULT 'N' ,
  `txn_id` VARCHAR(19) NULL DEFAULT NULL ,
  PRIMARY KEY (`lotto_id`) ,
  INDEX `fk_lotto_1` (`user_id` ASC) ,
  INDEX `created` (`created` ASC) ,
  INDEX `confirmed` (`confirmed` ASC, `created` ASC) ,
  INDEX `index5` (`winner` ASC, `created` ASC) ,
  INDEX `index6` (`txn_id` ASC) ,
  CONSTRAINT `fk_lotto_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
