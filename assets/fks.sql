SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

CREATE SCHEMA IF NOT EXISTS `tan` DEFAULT CHARACTER SET utf8 ;
USE `tan` ;

-- -----------------------------------------------------
-- Table `tan`.`user`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`user` (
  `user_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `username` VARCHAR(255) NOT NULL ,
  `join_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `email` VARCHAR(255) NOT NULL ,
  `password` VARCHAR(128) NOT NULL ,
  `confirmed` ENUM('N','Y') NOT NULL DEFAULT 'N' ,
  `deleted` ENUM('N','Y') NOT NULL DEFAULT 'N' ,
  PRIMARY KEY (`user_id`) )
ENGINE = InnoDB
AUTO_INCREMENT = 751
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`object`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`object` (
  `object_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `type` ENUM('link','blog','picture','profile','poll') NOT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `promoted` TIMESTAMP NULL DEFAULT NULL ,
  `user_id` BIGINT(20) NOT NULL ,
  `NSFW` ENUM('Y','N') NOT NULL DEFAULT 'N' ,
  PRIMARY KEY (`object_id`) ,
  INDEX `created` (`created` ASC) ,
  INDEX `super_index` (`NSFW` ASC, `type` ASC, `promoted` ASC, `created` ASC) ,
  INDEX `promoted` (`promoted` ASC) ,
  INDEX `profile` (`type` ASC, `user_id` ASC, `NSFW` ASC, `created` ASC) ,
  INDEX `fk_object_1` (`user_id` ASC) ,
  CONSTRAINT `fk_object_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 100336
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`picture`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`picture` (
  `picture_id` BIGINT(20) NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  `filename` VARCHAR(300) NOT NULL ,
  `x` INT(11) NOT NULL ,
  `y` INT(11) NOT NULL ,
  `size` INT(11) NOT NULL ,
  `sha512sum` VARCHAR(128) NOT NULL ,
  PRIMARY KEY (`picture_id`) ,
  INDEX `filenam` (`filename` ASC) ,
  INDEX `512sum` (`sha512sum` ASC) ,
  INDEX `fk_picture_1` (`picture_id` ASC) ,
  CONSTRAINT `fk_picture_1`
    FOREIGN KEY (`picture_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`blog`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`blog` (
  `blog_id` BIGINT(20) NOT NULL ,
  `picture_id` BIGINT(20) NOT NULL ,
  `details` MEDIUMTEXT NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  PRIMARY KEY (`blog_id`) ,
  INDEX `fk_blog_1` (`blog_id` ASC) ,
  INDEX `fk_blog_2` (`picture_id` ASC) ,
  CONSTRAINT `fk_blog_1`
    FOREIGN KEY (`blog_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_blog_2`
    FOREIGN KEY (`picture_id` )
    REFERENCES `tan`.`picture` (`picture_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


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
  INDEX `deleted` (`deleted` ASC) ,
  INDEX `created` (`created` ASC) ,
  INDEX `object` (`object_id` ASC, `deleted` ASC) ,
  INDEX `fk_comments_1` (`object_id` ASC) ,
  INDEX `fk_comments_2` (`user_id` ASC) ,
  CONSTRAINT `fk_comments_1`
    FOREIGN KEY (`object_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_comments_2`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 233845
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`link`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`link` (
  `link_id` BIGINT(20) NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  `picture_id` BIGINT(20) NOT NULL ,
  `url` VARCHAR(400) NOT NULL ,
  PRIMARY KEY (`link_id`) ,
  INDEX `fk_link_1` (`link_id` ASC) ,
  INDEX `fk_link_2` (`picture_id` ASC) ,
  CONSTRAINT `fk_link_1`
    FOREIGN KEY (`link_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_link_2`
    FOREIGN KEY (`picture_id` )
    REFERENCES `tan`.`picture` (`picture_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`old_lookup`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`old_lookup` (
  `new_id` BIGINT(20) NOT NULL ,
  `old_id` INT(11) NOT NULL ,
  `type` ENUM('link','blog','picture') NOT NULL ,
  INDEX `lookup` (`old_id` ASC, `type` ASC) ,
  INDEX `fk_old_lookup_1` (`new_id` ASC) ,
  CONSTRAINT `fk_old_lookup_1`
    FOREIGN KEY (`new_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


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
  INDEX `object_type` (`object_id` ASC, `type` ASC) ,
  INDEX `fk_plus_minus_1` (`object_id` ASC) ,
  INDEX `fk_plus_minus_2` (`user_id` ASC) ,
  CONSTRAINT `fk_plus_minus_1`
    FOREIGN KEY (`object_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_plus_minus_2`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 914671
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`poll`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`poll` (
  `poll_id` BIGINT(20) NOT NULL ,
  `picture_id` BIGINT(20) NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  `end_date` TIMESTAMP NULL DEFAULT NULL ,
  PRIMARY KEY (`poll_id`) ,
  INDEX `fk_poll_1` (`poll_id` ASC) ,
  INDEX `fk_poll_2` (`picture_id` ASC) ,
  CONSTRAINT `fk_poll_1`
    FOREIGN KEY (`poll_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_poll_2`
    FOREIGN KEY (`picture_id` )
    REFERENCES `tan`.`picture` (`picture_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`poll_answer`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`poll_answer` (
  `answer_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `poll_id` BIGINT(20) NOT NULL ,
  `answer` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`answer_id`) ,
  INDEX `fk_poll_answer_1` (`poll_id` ASC) ,
  CONSTRAINT `fk_poll_answer_1`
    FOREIGN KEY (`poll_id` )
    REFERENCES `tan`.`poll` (`poll_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 1540
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`poll_vote`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`poll_vote` (
  `vote_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `answer_id` BIGINT(20) NOT NULL ,
  `user_id` BIGINT(20) NOT NULL ,
  PRIMARY KEY (`vote_id`) ,
  INDEX `fk_poll_vote_1` (`answer_id` ASC) ,
  INDEX `fk_poll_vote_2` (`user_id` ASC) ,
  CONSTRAINT `fk_poll_vote_1`
    FOREIGN KEY (`answer_id` )
    REFERENCES `tan`.`poll_answer` (`answer_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_poll_vote_2`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 6589
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`profile`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`profile` (
  `profile_id` BIGINT(20) NOT NULL ,
  `details` MEDIUMTEXT NOT NULL ,
  PRIMARY KEY (`profile_id`) ,
  INDEX `fk_profile_1` (`profile_id` ASC) ,
  CONSTRAINT `fk_profile_1`
    FOREIGN KEY (`profile_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`tags`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`tags` (
  `tag_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `tag` VARCHAR(30) NOT NULL ,
  PRIMARY KEY (`tag_id`) )
ENGINE = InnoDB
AUTO_INCREMENT = 15411
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`tag_objects`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`tag_objects` (
  `object_tag_id` BIGINT(20) NOT NULL AUTO_INCREMENT ,
  `tag_id` BIGINT(20) NOT NULL ,
  `user_id` BIGINT(20) NOT NULL ,
  `object_id` BIGINT(20) NOT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (`object_tag_id`) ,
  INDEX `fk_tag_objects_1` (`tag_id` ASC) ,
  INDEX `fk_tag_objects_2` (`object_id` ASC) ,
  CONSTRAINT `fk_tag_objects_1`
    FOREIGN KEY (`tag_id` )
    REFERENCES `tan`.`tags` (`tag_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_tag_objects_2`
    FOREIGN KEY (`object_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 118979
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`user_tokens`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`user_tokens` (
  `token_id` INT(11) NOT NULL AUTO_INCREMENT ,
  `user_id` BIGINT(20) NOT NULL ,
  `token` VARCHAR(516) NOT NULL ,
  `expires` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  `type` ENUM('reg','forgot') NOT NULL ,
  PRIMARY KEY (`token_id`) ,
  INDEX `fk_user_tokens_1` (`user_id` ASC) ,
  CONSTRAINT `fk_user_tokens_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 285
DEFAULT CHARACTER SET = utf8;


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
  INDEX `session_objectid` (`object_id` ASC, `session_id` ASC, `type` ASC) ,
  INDEX `created` (`created` ASC) ,
  INDEX `fk_views_1` (`object_id` ASC) ,
  INDEX `fk_views_2` (`user_id` ASC) ,
  CONSTRAINT `fk_views_1`
    FOREIGN KEY (`object_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_views_2`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
AUTO_INCREMENT = 10133956
DEFAULT CHARACTER SET = utf8;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
