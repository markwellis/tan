CREATE  TABLE IF NOT EXISTS `tan`.`cms` (
  `cms_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `url` VARCHAR(255) NOT NULL ,
  `content` MEDIUMTEXT NOT NULL ,
  `user_id` BIGINT(20) NOT NULL ,
  `created` TIMESTAMP NOT NULL ,
  `updated` TIMESTAMP NULL DEFAULT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`cms_id`) ,
  INDEX `fk_cms_1` (`user_id` ASC) ,
  INDEX `index3` (`url` ASC) ,
  CONSTRAINT `fk_cms_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;