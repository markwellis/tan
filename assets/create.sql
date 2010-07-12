SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `tan` DEFAULT CHARACTER SET utf8 ;
USE `tan` ;

-- -----------------------------------------------------
-- Table `tan`.`user`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`user` (
  `user_id` BIGINT NOT NULL AUTO_INCREMENT ,
  `username` VARCHAR(255) NOT NULL ,
  `join_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `email` VARCHAR(255) NOT NULL ,
  `password` VARCHAR(128) NOT NULL ,
  `confirmed` ENUM('N','Y') NOT NULL DEFAULT 'N' ,
  `deleted` ENUM('N','Y') NOT NULL DEFAULT 'N' ,
  PRIMARY KEY (`user_id`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `tan`.`object`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`object` (
  `object_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `type` ENUM('link','blog','picture','profile') NOT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `promoted` TIMESTAMP NULL DEFAULT NULL ,
  `user_id` BIGINT(20) NOT NULL ,
  `NSFW` ENUM('Y','N') NOT NULL DEFAULT 'N' ,
  PRIMARY KEY (`object_id`) ,
  INDEX `o_user` (`user_id` ASC) ,
  INDEX `created` (`created` ASC) ,
  INDEX `super_index` (`NSFW` ASC, `type` ASC, `promoted` ASC, `created` ASC) ,
  INDEX `promoted` (`promoted` ASC) ,
  INDEX `profile` (`type` ASC, `user_id` ASC, `NSFW` ASC, `created` ASC) ,
  CONSTRAINT `o_user`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
AUTO_INCREMENT = 53016
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `tan`.`views`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`views` (
  `view_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `ip` VARCHAR(15) NOT NULL ,
  `object_id` BIGINT(20) NOT NULL ,
  `session_id` VARCHAR(128) NOT NULL ,
  `user_id` BIGINT(20) NULL DEFAULT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `type` ENUM('internal','external') NOT NULL DEFAULT 'internal' ,
  PRIMARY KEY (`view_id`) ,
  INDEX `v_user` (`user_id` ASC) ,
  INDEX `v_object` (`object_id` ASC) ,
  INDEX `session_objectid` (`object_id` ASC, `session_id` ASC, `type` ASC) ,
  CONSTRAINT `v_user`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `v_object`
    FOREIGN KEY (`object_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
AUTO_INCREMENT = 3397802
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `tan`.`user_tokens`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`user_tokens` (
  `token_id` INT NOT NULL AUTO_INCREMENT ,
  `user_id` BIGINT NOT NULL ,
  `token` VARCHAR(516) NOT NULL ,
  `expires` TIMESTAMP NOT NULL ,
  `type` ENUM('reg','forgot') NOT NULL ,
  PRIMARY KEY (`token_id`) ,
  INDEX `ut_user` (`user_id` ASC) ,
  CONSTRAINT `ut_user`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `tan`.`tags`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`tags` (
  `tag_id` BIGINT NOT NULL AUTO_INCREMENT ,
  `tag` VARCHAR(30) NOT NULL ,
  PRIMARY KEY (`tag_id`) )
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `tan`.`tag_objects`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`tag_objects` (
  `object_tag_id` BIGINT NOT NULL AUTO_INCREMENT ,
  `tag_id` BIGINT NOT NULL ,
  `user_id` BIGINT NOT NULL ,
  `object_id` BIGINT NOT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (`object_tag_id`) ,
  INDEX `tags` (`tag_id` ASC) ,
  INDEX `t_object` (`object_id` ASC) ,
  CONSTRAINT `tags`
    FOREIGN KEY (`tag_id` )
    REFERENCES `tan`.`tags` (`tag_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `t_object`
    FOREIGN KEY (`object_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `tan`.`comments`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`comments` (
  `comment_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `user_id` BIGINT(20) NOT NULL ,
  `comment` MEDIUMTEXT NOT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `object_id` BIGINT(20) NOT NULL ,
  `deleted` ENUM('Y','N') NOT NULL DEFAULT 'N' ,
  `number` BIGINT(20) NOT NULL ,
  PRIMARY KEY (`comment_id`) ,
  INDEX `c_user` (`user_id` ASC) ,
  INDEX `c_object` (`object_id` ASC) ,
  INDEX `deleted` (`deleted` ASC) ,
  INDEX `created` (`created` ASC) ,
  INDEX `object` (`object_id` ASC, `deleted` ASC) ,
  CONSTRAINT `c_user`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `c_object`
    FOREIGN KEY (`object_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
AUTO_INCREMENT = 58860
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `tan`.`picture`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`picture` (
  `picture_id` BIGINT NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  `filename` VARCHAR(300) NOT NULL ,
  `x` INT NOT NULL ,
  `y` INT NOT NULL ,
  `size` INT NOT NULL ,
  `sha512sum` VARCHAR(128) NOT NULL ,
  PRIMARY KEY (`picture_id`) ,
  INDEX `p_object` (`picture_id` ASC) ,
  INDEX `filenam` (`filename` ASC) ,
  INDEX `512sum` (`sha512sum` ASC) ,
  CONSTRAINT `p_object`
    FOREIGN KEY (`picture_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `tan`.`blog`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`blog` (
  `blog_id` BIGINT NOT NULL ,
  `picture_id` BIGINT NOT NULL ,
  `details` MEDIUMTEXT NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  PRIMARY KEY (`blog_id`) ,
  INDEX `b_object` (`blog_id` ASC) ,
  INDEX `b_image` (`picture_id` ASC) ,
  CONSTRAINT `b_object`
    FOREIGN KEY (`blog_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `b_image`
    FOREIGN KEY (`picture_id` )
    REFERENCES `tan`.`picture` (`picture_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `tan`.`link`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`link` (
  `link_id` BIGINT NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  `picture_id` BIGINT NOT NULL ,
  `url` VARCHAR(400) NOT NULL ,
  INDEX `l_image` (`picture_id` ASC) ,
  INDEX `l_object` (`link_id` ASC) ,
  PRIMARY KEY (`link_id`) ,
  CONSTRAINT `l_image`
    FOREIGN KEY (`picture_id` )
    REFERENCES `tan`.`picture` (`picture_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `l_object`
    FOREIGN KEY (`link_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM;


-- -----------------------------------------------------
-- Table `tan`.`old_lookup`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`old_lookup` (
  `new_id` BIGINT(20) NOT NULL ,
  `old_id` INT(11) NOT NULL ,
  `type` ENUM('link','blog','picture','user') NOT NULL ,
  INDEX `ol_object` (`new_id` ASC) ,
  INDEX `lookup` (`old_id` ASC, `type` ASC) ,
  CONSTRAINT `ol_object`
    FOREIGN KEY (`new_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `tan`.`plus_minus`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`plus_minus` (
  `plus_minus_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `type` ENUM('plus','minus') NOT NULL ,
  `object_id` BIGINT(20) NOT NULL ,
  `user_id` BIGINT(20) NOT NULL ,
  PRIMARY KEY (`plus_minus_id`) ,
  INDEX `type` (`type` ASC) ,
  INDEX `user_id` (`user_id` ASC) ,
  INDEX `object_id` (`object_id` ASC) ,
  INDEX `object_type` (`object_id` ASC, `type` ASC) ,
  CONSTRAINT `fk_plus_minus_2`
    FOREIGN KEY (`object_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM
AUTO_INCREMENT = 459434
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `tan`.`profile`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`profile` (
  `profile_id` BIGINT NOT NULL ,
  `details` MEDIUMTEXT NOT NULL ,
  PRIMARY KEY (`profile_id`) ,
  INDEX `b_object` (`profile_id` ASC) ,
  CONSTRAINT `b_object`
    FOREIGN KEY (`profile_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = MyISAM;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
