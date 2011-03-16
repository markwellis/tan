CREATE  TABLE IF NOT EXISTS `tan`.`admin` (
  `admin_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `role` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`admin_id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;
show warnings;

CREATE  TABLE IF NOT EXISTS `tan`.`user_admin` (
  `user_id` BIGINT(20) NOT NULL ,
  `admin_id` BIGINT(20) NOT NULL ,
  INDEX `fk_user_admin_1` (`user_id` ASC) ,
  INDEX `fk_user_admin_2` (`admin_id` ASC) ,
  PRIMARY KEY (`user_id`, `admin_id`) ,
  CONSTRAINT `fk_user_admin_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_user_admin_2`
    FOREIGN KEY (`admin_id` )
    REFERENCES `tan`.`admin` (`admin_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;
show warnings;

INSERT INTO admin (role) VALUES('edit_object'),
    ('delete_object'),
    ('edit_user'),
    ('delete_user'),
    ('ban_user'),
    ('edit_comment'),
    ('admin_add_user'),
    ('admin_remove_user'),
    ('god');
show warnings;
