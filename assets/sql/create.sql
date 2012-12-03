SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';

CREATE SCHEMA IF NOT EXISTS `tan` DEFAULT CHARACTER SET utf8 ;
USE `tan` ;

-- -----------------------------------------------------
-- Table `tan`.`admin`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`admin` (
  `admin_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `role` VARCHAR(255) NOT NULL ,
  PRIMARY KEY (`admin_id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`user`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`user` (
  `user_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `username` VARCHAR(255) NOT NULL ,
  `join_date` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `email` VARCHAR(255) NOT NULL ,
  `password` VARCHAR(128) NOT NULL ,
  `confirmed` TINYINT(1) NOT NULL DEFAULT '0' ,
  `deleted` TINYINT(1) NOT NULL DEFAULT '0' ,
  `paypal` VARCHAR(255) NOT NULL ,
  `avatar` VARCHAR(10) NULL DEFAULT NULL ,
  `tcs` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  PRIMARY KEY (`user_id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`object`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`object` (
  `object_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `type` ENUM('link','blog','picture','profile','poll','video','forum') NOT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `promoted` TIMESTAMP NULL DEFAULT NULL ,
  `user_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `nsfw` TINYINT(1) NOT NULL DEFAULT '0' ,
  `views` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0' ,
  `plus` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0' ,
  `minus` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0' ,
  `comments` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0' ,
  `deleted` TINYINT(1) NOT NULL DEFAULT '0' ,
  `score` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `locked` TINYINT(1) NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`object_id`) ,
  INDEX `created` (`created` ASC) ,
  INDEX `promoted` (`promoted` ASC) ,
  INDEX `profile` (`type` ASC, `user_id` ASC, `nsfw` ASC, `created` ASC) ,
  INDEX `super_index` (`nsfw` ASC, `type` ASC, `promoted` ASC, `created` ASC, `deleted` ASC) ,
  INDEX `fk_object_1` (`user_id` ASC) ,
  CONSTRAINT `fk_object_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`comments`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`comments` (
  `comment_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `comment` MEDIUMTEXT NOT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `object_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `deleted` TINYINT(1) NOT NULL DEFAULT '0' ,
  `number` MEDIUMINT(8) UNSIGNED NOT NULL ,
  PRIMARY KEY (`comment_id`) ,
  INDEX `recent` (`created` ASC, `object_id` ASC, `deleted` ASC) ,
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
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`admin_log`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`admin_log` (
  `log_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `admin_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `action` VARCHAR(255) NOT NULL ,
  `reason` VARCHAR(512) NOT NULL ,
  `bulk` LONGTEXT NULL DEFAULT NULL ,
  `user_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `comment_id` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `object_id` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `other` TEXT NULL DEFAULT NULL ,
  PRIMARY KEY (`log_id`) ,
  INDEX `fk_admin_log_1` (`admin_id` ASC) ,
  INDEX `fk_admin_log_2` (`user_id` ASC) ,
  INDEX `fk_admin_log_3` (`object_id` ASC) ,
  INDEX `fk_admin_log_4` (`comment_id` ASC) ,
  CONSTRAINT `fk_admin_log_1`
    FOREIGN KEY (`admin_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_admin_log_2`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_admin_log_3`
    FOREIGN KEY (`object_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_admin_log_4`
    FOREIGN KEY (`comment_id` )
    REFERENCES `tan`.`comments` (`comment_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`picture`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`picture` (
  `picture_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  `filename` VARCHAR(300) NOT NULL ,
  `x` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `y` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `size` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `sha512sum` VARCHAR(128) NOT NULL ,
  PRIMARY KEY (`picture_id`) ,
  INDEX `filenam` (`filename`(255) ASC) ,
  INDEX `512sum` (`sha512sum` ASC) ,
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
  `blog_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `picture_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `details` MEDIUMTEXT NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  PRIMARY KEY (`blog_id`) ,
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
-- Table `tan`.`cms`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`cms` (
  `cms_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `url` VARCHAR(255) NOT NULL ,
  `content` MEDIUMTEXT NOT NULL ,
  `user_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `revision` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
  `title` VARCHAR(255) NOT NULL ,
  `comment` VARCHAR(255) NOT NULL ,
  `deleted` TINYINT(1) NOT NULL DEFAULT '0' ,
  `system` TINYINT(1) NOT NULL DEFAULT '0' ,
  `nowrapper` TINYINT(1) NOT NULL DEFAULT '0' ,
  PRIMARY KEY (`cms_id`) ,
  INDEX `url` (`url` ASC) ,
  INDEX `revision` (`revision` ASC) ,
  INDEX `deleted` (`deleted` ASC) ,
  INDEX `fk_cms_1` (`user_id` ASC) ,
  CONSTRAINT `fk_cms_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`forum`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`forum` (
  `forum_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `picture_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `details` MEDIUMTEXT NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  PRIMARY KEY (`forum_id`) ,
  INDEX `fk_forum_2` (`picture_id` ASC) ,
  CONSTRAINT `fk_forum_1`
    FOREIGN KEY (`forum_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_forum_2`
    FOREIGN KEY (`picture_id` )
    REFERENCES `tan`.`picture` (`picture_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`link`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`link` (
  `link_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  `picture_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `url` VARCHAR(400) NOT NULL ,
  PRIMARY KEY (`link_id`) ,
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
-- Table `tan`.`lotto`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`lotto` (
  `lotto_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `user_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `number` TINYINT(3) UNSIGNED NOT NULL ,
  `confirmed` TINYINT(1) NOT NULL DEFAULT '0' ,
  `winner` TINYINT(1) NOT NULL DEFAULT '0' ,
  `txn_id` VARCHAR(19) NULL DEFAULT NULL ,
  PRIMARY KEY (`lotto_id`) ,
  INDEX `created` (`created` ASC) ,
  INDEX `confirmed` (`confirmed` ASC, `created` ASC) ,
  INDEX `index5` (`winner` ASC, `created` ASC) ,
  INDEX `index6` (`txn_id` ASC) ,
  INDEX `fk_lotto_1` (`user_id` ASC) ,
  CONSTRAINT `fk_lotto_1`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`plus_minus`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`plus_minus` (
  `plus_minus_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `type` ENUM('plus','minus') NOT NULL ,
  `object_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `user_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  PRIMARY KEY (`plus_minus_id`) ,
  INDEX `type` (`type` ASC) ,
  INDEX `object_type` (`object_id` ASC, `type` ASC) ,
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
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`poll`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`poll` (
  `poll_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `picture_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  `end_date` TIMESTAMP NULL DEFAULT NULL ,
  `votes` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0' ,
  PRIMARY KEY (`poll_id`) ,
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
  `answer_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `poll_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `answer` VARCHAR(255) NOT NULL ,
  `votes` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT '0' ,
  PRIMARY KEY (`answer_id`) ,
  INDEX `fk_poll_answer_1` (`poll_id` ASC) ,
  CONSTRAINT `fk_poll_answer_1`
    FOREIGN KEY (`poll_id` )
    REFERENCES `tan`.`poll` (`poll_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`poll_vote`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`poll_vote` (
  `vote_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `answer_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `user_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  PRIMARY KEY (`vote_id`) ,
  INDEX `fk_poll_vote_1` (`answer_id` ASC) ,
  INDEX `fk_poll_vote_2` (`user_id` ASC) ,
  CONSTRAINT `fk_poll_vote_1`
    FOREIGN KEY (`answer_id` )
    REFERENCES `tan`.`poll_answer` (`answer_id` )
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_poll_vote_2`
    FOREIGN KEY (`user_id` )
    REFERENCES `tan`.`user` (`user_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`profile`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`profile` (
  `profile_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `details` MEDIUMTEXT NOT NULL ,
  PRIMARY KEY (`profile_id`) ,
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
  `tag_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `tag` VARCHAR(30) NOT NULL ,
  `stem` VARCHAR(30) NOT NULL ,
  PRIMARY KEY (`tag_id`) ,
  INDEX `tag` (`tag` ASC) ,
  INDEX `stem` (`stem` ASC) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`tag_objects`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`tag_objects` (
  `object_tag_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `tag_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `object_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
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
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`user_admin`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`user_admin` (
  `user_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `admin_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  PRIMARY KEY (`user_id`, `admin_id`) ,
  INDEX `fk_user_admin_2` (`admin_id` ASC) ,
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
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`user_tokens`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`user_tokens` (
  `token_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `user_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
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
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`video`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`video` (
  `video_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  `picture_id` MEDIUMINT(8) UNSIGNED NOT NULL ,
  `url` VARCHAR(400) NOT NULL ,
  PRIMARY KEY (`video_id`) ,
  INDEX `fk_video_2` (`picture_id` ASC) ,
  CONSTRAINT `fk_video_1`
    FOREIGN KEY (`video_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_video_2`
    FOREIGN KEY (`picture_id` )
    REFERENCES `tan`.`picture` (`picture_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Table `tan`.`views`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `tan`.`views` (
  `view_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT ,
  `ip` VARCHAR(15) NOT NULL ,
  `object_id` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `session_id` VARCHAR(128) NOT NULL ,
  `user_id` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL ,
  `created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  `type` ENUM('internal','external') NOT NULL DEFAULT 'internal' ,
  PRIMARY KEY (`view_id`) ,
  INDEX `session_objectid` (`object_id` ASC, `session_id` ASC, `type` ASC) ,
  INDEX `created` (`created` ASC) ,
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
DEFAULT CHARACTER SET = utf8;


-- -----------------------------------------------------
-- Placeholder table for view `tan`.`recent_comments`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `tan`.`recent_comments` (`comment_id` INT, `comment` INT, `created` INT, `object_id` INT, `type` INT, `nsfw` INT, `link_title` INT, `picture_title` INT, `blog_title` INT, `poll_title` INT, `video_title` INT, `forum_title` INT, `username` INT);

-- -----------------------------------------------------
-- View `tan`.`recent_comments`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tan`.`recent_comments`;
USE `tan`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `tan`.`recent_comments` AS select `me`.`comment_id` AS `comment_id`,`me`.`comment` AS `comment`,`me`.`created` AS `created`,`me`.`object_id` AS `object_id`,`tan`.`object`.`type` AS `type`,`tan`.`object`.`nsfw` AS `nsfw`,`tan`.`link`.`title` AS `link_title`,`tan`.`picture`.`title` AS `picture_title`,`tan`.`blog`.`title` AS `blog_title`,`tan`.`poll`.`title` AS `poll_title`,`tan`.`video`.`title` AS `video_title`,`tan`.`forum`.`title` AS `forum_title`,`tan`.`user`.`username` AS `username` from ((((((((`tan`.`comments` `me` USE INDEX (`recent`) join `tan`.`object` on((`tan`.`object`.`object_id` = `me`.`object_id`))) left join `tan`.`link` on((`tan`.`link`.`link_id` = `me`.`object_id`))) left join `tan`.`picture` on((`tan`.`picture`.`picture_id` = `me`.`object_id`))) left join `tan`.`blog` on((`tan`.`blog`.`blog_id` = `me`.`object_id`))) left join `tan`.`poll` on((`tan`.`poll`.`poll_id` = `me`.`object_id`))) left join `tan`.`video` on((`tan`.`video`.`video_id` = `me`.`object_id`))) left join `tan`.`forum` on((`tan`.`forum`.`forum_id` = `me`.`object_id`))) join `tan`.`user` on((`tan`.`user`.`user_id` = `me`.`user_id`))) where ((`me`.`deleted` = 0) and (`tan`.`object`.`deleted` = 0)) order by `me`.`created` desc limit 20;
USE `tan`;

DELIMITER $$
USE `tan`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `tan`.`decrement_object_comments`
AFTER UPDATE ON `tan`.`comments`
FOR EACH ROW
BEGIN

IF NEW.deleted THEN
	UPDATE object SET comments=comments-1 WHERE object_id=NEW.object_id;
END IF;

END$$

USE `tan`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `tan`.`increment_object_comments`
AFTER INSERT ON `tan`.`comments`
FOR EACH ROW
BEGIN

UPDATE object SET comments=comments+1 WHERE object_id=NEW.object_id;

END$$


DELIMITER ;

DELIMITER $$
USE `tan`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `tan`.`decrement_object_plus_minus`
AFTER DELETE ON `tan`.`plus_minus`
FOR EACH ROW
BEGIN

IF OLD.type = 'plus' THEN
	UPDATE object SET plus=plus-1 WHERE object_id=OLD.object_id;
ELSEIF OLD.type = 'minus' THEN
	UPDATE object SET minus=minus-1 WHERE object_id=OLD.object_id;
END IF;

END$$

USE `tan`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `tan`.`increment_object_plus_minus`
AFTER INSERT ON `tan`.`plus_minus`
FOR EACH ROW
BEGIN

IF NEW.type = 'plus' THEN
	UPDATE object SET plus=plus+1 WHERE object_id=NEW.object_id;
ELSEIF NEW.type = 'minus' THEN
	UPDATE object SET minus=minus+1 WHERE object_id=NEW.object_id;
END IF;

END$$


DELIMITER ;

DELIMITER $$
USE `tan`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `tan`.`increment_poll_votes`
AFTER INSERT ON `tan`.`poll_vote`
FOR EACH ROW
BEGIN

UPDATE poll_answer SET votes=votes+1 WHERE answer_id=NEW.answer_id;
UPDATE poll SET poll.votes=poll.votes+1 WHERE poll.poll_id=( SELECT poll_answer.poll_id FROM poll_answer WHERE poll_answer.answer_id = NEW.answer_id );

END$$


DELIMITER ;

DELIMITER $$
USE `tan`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `tan`.`increment_object_views`
AFTER INSERT ON `tan`.`views`
FOR EACH ROW
BEGIN

IF NEW.object_id IS NOT NULL THEN
	UPDATE object SET views=views+1 WHERE object_id=NEW.object_id;
END IF;

END$$


DELIMITER ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
