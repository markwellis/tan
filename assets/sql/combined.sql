SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

ALTER TABLE `tan`.`comments` CHANGE COLUMN `deleted` `deleted` VARCHAR(1) NOT NULL DEFAULT 0  ;

ALTER TABLE `tan`.`object` CHANGE COLUMN `NSFW` `nsfw` VARCHAR(1) NOT NULL DEFAULT 0  , CHANGE COLUMN `deleted` `deleted` VARCHAR(1) NOT NULL DEFAULT 0  ;

ALTER TABLE `tan`.`user` CHANGE COLUMN `confirmed` `confirmed` VARCHAR(1) NOT NULL DEFAULT 0  , CHANGE COLUMN `deleted` `deleted` VARCHAR(1) NOT NULL DEFAULT 0  ;

ALTER TABLE `tan`.`cms` CHANGE COLUMN `deleted` `deleted` VARCHAR(1) NOT NULL DEFAULT 0  , CHANGE COLUMN `system` `system` VARCHAR(1) NOT NULL DEFAULT 0  , CHANGE COLUMN `nowrapper` `nowrapper` VARCHAR(1) NOT NULL DEFAULT 0  ;

ALTER TABLE `tan`.`lotto` CHANGE COLUMN `confirmed` `confirmed` VARCHAR(1) NOT NULL DEFAULT 0  , CHANGE COLUMN `winner` `winner` VARCHAR(1) NOT NULL DEFAULT 0  ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
UPDATE comments SET deleted = 1 WHERE deleted = 'Y';
UPDATE comments SET deleted = 0 WHERE deleted = 'N';

UPDATE object SET nsfw = 1 WHERE nsfw = 'Y';
UPDATE object SET nsfw = 0 WHERE nsfw = 'N';
UPDATE object SET deleted = 1 WHERE deleted = 'Y';
UPDATE object SET deleted = 0 WHERE deleted = 'N';

UPDATE user SET confirmed = 1 WHERE confirmed = 'Y';
UPDATE user SET confirmed = 0 WHERE confirmed = 'N';
UPDATE user SET deleted = 1 WHERE deleted = 'Y';
UPDATE user SET deleted = 0 WHERE deleted = 'N';

UPDATE cms SET deleted = 1 WHERE deleted = 'Y';
UPDATE cms SET deleted = 0 WHERE deleted = 'N';
UPDATE cms SET system = 1 WHERE system = 'Y';
UPDATE cms SET system = 0 WHERE system = 'N';
UPDATE cms SET nowrapper = 1 WHERE nowrapper = 'Y';
UPDATE cms SET nowrapper = 0 WHERE nowrapper = 'N';

UPDATE lotto SET confirmed = 1 WHERE confirmed = 'Y';
UPDATE lotto SET confirmed = 0 WHERE confirmed = 'N';
UPDATE lotto SET winner = 1 WHERE winner = 'y';
UPDATE lotto SET winner = 0 WHERE winner = 'n';
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

ALTER TABLE `tan`.`comments` CHANGE COLUMN `deleted` `deleted` TINYINT(1) NOT NULL DEFAULT 0  ;

ALTER TABLE `tan`.`object` CHANGE COLUMN `NSFW` `nsfw` TINYINT(1) NOT NULL DEFAULT 0  , CHANGE COLUMN `deleted` `deleted` TINYINT(1) NOT NULL DEFAULT 0  ;

ALTER TABLE `tan`.`user` CHANGE COLUMN `confirmed` `confirmed` TINYINT(1) NOT NULL DEFAULT 0  , CHANGE COLUMN `deleted` `deleted` TINYINT(1) NOT NULL DEFAULT 0  ;

ALTER TABLE `tan`.`cms` CHANGE COLUMN `deleted` `deleted` TINYINT(1) NOT NULL DEFAULT 0  , CHANGE COLUMN `system` `system` TINYINT(1) NOT NULL DEFAULT 0  , CHANGE COLUMN `nowrapper` `nowrapper` TINYINT(1) NOT NULL DEFAULT 0  ;

ALTER TABLE `tan`.`lotto` CHANGE COLUMN `confirmed` `confirmed` TINYINT(1) NOT NULL DEFAULT 0  , CHANGE COLUMN `winner` `winner` TINYINT(1) NOT NULL DEFAULT 0  ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
ALTER TABLE `tan`.`tag_objects` DROP COLUMN `created` ;SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';


-- -----------------------------------------------------
-- Placeholder table for view `tan`.`recent_comments`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `tan`.`recent_comments` (`comment_id` INT, `comment` INT, `created` INT, `object_id` INT, `type` INT, `nsfw` INT, `link_title` INT, `picture_title` INT, `blog_title` INT, `poll_title` INT, `video_title` INT, `forum_title` INT, `username` INT);


USE `tan`;

-- -----------------------------------------------------
-- View `tan`.`recent_comments`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tan`.`recent_comments`;
USE `tan`;
CREATE  OR REPLACE VIEW `tan`.`recent_comments` AS

SELECT me.comment_id, me.comment, me.created, me.object_id, object.type, object.nsfw, link.title link_title, picture.title picture_title, blog.title blog_title, poll.title poll_title, video.title video_title, forum.title forum_title, user.username FROM comments me USE INDEX (recent) JOIN object object ON object.object_id = me.object_id LEFT JOIN link link ON link.link_id = me.object_id LEFT JOIN picture picture ON picture.picture_id = me.object_id LEFT JOIN blog blog ON blog.blog_id = me.object_id LEFT JOIN poll poll ON poll.poll_id = me.object_id LEFT JOIN video video ON video.video_id = me.object_id LEFT JOIN forum forum ON forum.forum_id = me.object_id JOIN user user ON user.user_id = me.user_id WHERE ( me.deleted = 0 ) AND ( object.deleted = 0 ) ORDER BY me.created DESC LIMIT 20;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';


DELIMITER $$

USE `tan`$$
DROP TRIGGER IF EXISTS `tan`.`decrement_object_comments` $$


DELIMITER ;


DELIMITER $$

USE `tan`$$


Create Trigger decrement_object_comments
	AFTER UPDATE ON comments
	FOR EACH ROW
BEGIN

IF NEW.deleted THEN
	UPDATE object SET comments=comments-1 WHERE object_id=NEW.object_id;
END IF;

END$$


DELIMITER ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DROP TABLE IF EXISTS `tan`.`old_lookup` ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
ALTER TABLE `tan`.`blog` DROP FOREIGN KEY `fk_blog_1` , DROP FOREIGN KEY `fk_blog_2` ;
ALTER TABLE `tan`.`blog` DROP KEY `fk_blog_1` , DROP KEY `fk_blog_2` ;

ALTER TABLE `tan`.`comments` DROP FOREIGN KEY `fk_comments_1` , DROP FOREIGN KEY `fk_comments_2` ;
ALTER TABLE `tan`.`comments` DROP KEY `fk_comments_1` , DROP KEY `fk_comments_2` ;

ALTER TABLE `tan`.`link` DROP FOREIGN KEY `fk_link_1` , DROP FOREIGN KEY `fk_link_2` ;
ALTER TABLE `tan`.`link` DROP KEY `fk_link_1` , DROP KEY `fk_link_2` ;

ALTER TABLE `tan`.`object` DROP FOREIGN KEY `fk_object_1` ;
ALTER TABLE `tan`.`object` DROP KEY `fk_object_1` ;

ALTER TABLE `tan`.`picture` DROP FOREIGN KEY `fk_picture_1` ;
ALTER TABLE `tan`.`picture` DROP KEY `fk_picture_1` ;

ALTER TABLE `tan`.`plus_minus` DROP FOREIGN KEY `fk_plus_minus_1` , DROP FOREIGN KEY `fk_plus_minus_2` ;
ALTER TABLE `tan`.`plus_minus` DROP KEY `fk_plus_minus_1` , DROP KEY `fk_plus_minus_2` ;

ALTER TABLE `tan`.`poll` DROP FOREIGN KEY `fk_poll_1` , DROP FOREIGN KEY `fk_poll_2` ;
ALTER TABLE `tan`.`poll` DROP KEY `fk_poll_1` , DROP KEY `fk_poll_2` ;

ALTER TABLE `tan`.`poll_answer` DROP FOREIGN KEY `fk_poll_answer_1` ;
ALTER TABLE `tan`.`poll_answer` DROP KEY `fk_poll_answer_1` ;

ALTER TABLE `tan`.`poll_vote` DROP FOREIGN KEY `fk_poll_vote_1` , DROP FOREIGN KEY `fk_poll_vote_2` ;
ALTER TABLE `tan`.`poll_vote` DROP KEY `fk_poll_vote_1` , DROP KEY `fk_poll_vote_2` ;

ALTER TABLE `tan`.`profile` DROP FOREIGN KEY `fk_profile_1` ;
ALTER TABLE `tan`.`profile` DROP KEY `fk_profile_1` ;

ALTER TABLE `tan`.`tag_objects` DROP FOREIGN KEY `fk_tag_objects_1` , DROP FOREIGN KEY `fk_tag_objects_2` ;
ALTER TABLE `tan`.`tag_objects` DROP KEY `fk_tag_objects_1` , DROP KEY `fk_tag_objects_2` ;

ALTER TABLE `tan`.`user_tokens` DROP FOREIGN KEY `fk_user_tokens_1` ;
ALTER TABLE `tan`.`user_tokens` DROP KEY `fk_user_tokens_1` ;

ALTER TABLE `tan`.`views` DROP FOREIGN KEY `fk_views_1` , DROP FOREIGN KEY `fk_views_2` ;
ALTER TABLE `tan`.`views` DROP KEY `fk_views_1` , DROP KEY `fk_views_2` ;

ALTER TABLE `tan`.`user_admin` DROP FOREIGN KEY `fk_user_admin_1` , DROP FOREIGN KEY `fk_user_admin_2` ;
ALTER TABLE `tan`.`user_admin` DROP KEY `fk_user_admin_1` , DROP KEY `fk_user_admin_2` ;

ALTER TABLE `tan`.`admin_log` DROP FOREIGN KEY `fk_admin_id` , DROP FOREIGN KEY `fk_user_id` , DROP FOREIGN KEY `fk_object_id` , DROP FOREIGN KEY `fk_comment_id` ;
ALTER TABLE `tan`.`admin_log` DROP KEY `fk_admin_id` , DROP KEY `fk_user_id` , DROP KEY `fk_object_id` , DROP KEY `fk_comment_id` ;

ALTER TABLE `tan`.`video` DROP FOREIGN KEY `fk_video_10` , DROP FOREIGN KEY `fk_video_20` ;
ALTER TABLE `tan`.`video` DROP KEY `fk_video_1` , DROP KEY `fk_video_2` ;

ALTER TABLE `tan`.`forum` DROP FOREIGN KEY `fk_blog_10` , DROP FOREIGN KEY `fk_blog_20` ;
ALTER TABLE `tan`.`forum` DROP KEY `fk_forum_1` , DROP KEY `fk_forum_2` ;

ALTER TABLE `tan`.`cms` DROP FOREIGN KEY `fk_cms_1` ;
ALTER TABLE `tan`.`cms` DROP KEY `fk_cms_1` ;

ALTER TABLE `tan`.`lotto` DROP FOREIGN KEY `fk_lotto_1` ;
ALTER TABLE `tan`.`lotto` DROP KEY `fk_lotto_1` ;
ALTER TABLE `tan`.`blog` CHANGE COLUMN `blog_id` `blog_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `picture_id` `picture_id` MEDIUMINT(8) UNSIGNED NOT NULL;

ALTER TABLE `tan`.`comments` CHANGE COLUMN `comment_id` `comment_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  , CHANGE COLUMN `user_id` `user_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `object_id` `object_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `number` `number` MEDIUMINT(8) UNSIGNED NOT NULL;

ALTER TABLE `tan`.`link` CHANGE COLUMN `link_id` `link_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `picture_id` `picture_id` MEDIUMINT(8) UNSIGNED NOT NULL;

ALTER TABLE `tan`.`object` CHANGE COLUMN `object_id` `object_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  , CHANGE COLUMN `user_id` `user_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `views` `views` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT 0  , CHANGE COLUMN `plus` `plus` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT 0  , CHANGE COLUMN `minus` `minus` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT 0  , CHANGE COLUMN `comments` `comments` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT 0  , CHANGE COLUMN `score` `score` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL;

ALTER TABLE `tan`.`picture` CHANGE COLUMN `picture_id` `picture_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `x` `x` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `y` `y` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `size` `size` MEDIUMINT(8) UNSIGNED NOT NULL;

ALTER TABLE `tan`.`plus_minus` CHANGE COLUMN `plus_minus_id` `plus_minus_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  , CHANGE COLUMN `object_id` `object_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `user_id` `user_id` MEDIUMINT(8) UNSIGNED NOT NULL;

ALTER TABLE `tan`.`poll` CHANGE COLUMN `poll_id` `poll_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `picture_id` `picture_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `votes` `votes` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT 0;

ALTER TABLE `tan`.`poll_answer` CHANGE COLUMN `answer_id` `answer_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  , CHANGE COLUMN `poll_id` `poll_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `votes` `votes` MEDIUMINT(8) UNSIGNED NOT NULL DEFAULT 0;

ALTER TABLE `tan`.`poll_vote` CHANGE COLUMN `vote_id` `vote_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  , CHANGE COLUMN `answer_id` `answer_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `user_id` `user_id` MEDIUMINT(8) UNSIGNED NOT NULL;

ALTER TABLE `tan`.`profile` CHANGE COLUMN `profile_id` `profile_id` MEDIUMINT(8) UNSIGNED NOT NULL;

ALTER TABLE `tan`.`tag_objects` DROP COLUMN `user_id` , CHANGE COLUMN `object_tag_id` `object_tag_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  , CHANGE COLUMN `tag_id` `tag_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `object_id` `object_id` MEDIUMINT(8) UNSIGNED NOT NULL;

ALTER TABLE `tan`.`tags` CHANGE COLUMN `tag_id` `tag_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  ;

ALTER TABLE `tan`.`user` CHANGE COLUMN `user_id` `user_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  , CHANGE COLUMN `tcs` `tcs` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL  ;

ALTER TABLE `tan`.`user_tokens` CHANGE COLUMN `token_id` `token_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  , CHANGE COLUMN `user_id` `user_id` MEDIUMINT(8) UNSIGNED NOT NULL;

ALTER TABLE `tan`.`views` CHANGE COLUMN `view_id` `view_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  , CHANGE COLUMN `object_id` `object_id` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL  , CHANGE COLUMN `user_id` `user_id` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL;

ALTER TABLE `tan`.`user_admin` CHANGE COLUMN `user_id` `user_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `admin_id` `admin_id` MEDIUMINT(8) UNSIGNED NOT NULL;

ALTER TABLE `tan`.`admin` CHANGE COLUMN `admin_id` `admin_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  ;

ALTER TABLE `tan`.`admin_log` CHANGE COLUMN `log_id` `log_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  , CHANGE COLUMN `admin_id` `admin_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `user_id` `user_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `comment_id` `comment_id` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL  , CHANGE COLUMN `object_id` `object_id` MEDIUMINT(8) UNSIGNED NULL DEFAULT NULL;

ALTER TABLE `tan`.`video` CHANGE COLUMN `video_id` `video_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `picture_id` `picture_id` MEDIUMINT(8) UNSIGNED NOT NULL;

ALTER TABLE `tan`.`forum` CHANGE COLUMN `forum_id` `forum_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `picture_id` `picture_id` MEDIUMINT(8) UNSIGNED NOT NULL;

ALTER TABLE `tan`.`cms` CHANGE COLUMN `cms_id` `cms_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  , CHANGE COLUMN `user_id` `user_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `revision` `revision` MEDIUMINT(8) UNSIGNED NOT NULL;

ALTER TABLE `tan`.`lotto` CHANGE COLUMN `lotto_id` `lotto_id` MEDIUMINT(8) UNSIGNED NOT NULL AUTO_INCREMENT  , CHANGE COLUMN `user_id` `user_id` MEDIUMINT(8) UNSIGNED NOT NULL  , CHANGE COLUMN `number` `number` TINYINT(3) UNSIGNED NOT NULL;
ALTER TABLE `tan`.`blog`   ADD CONSTRAINT `fk_blog_1`
  FOREIGN KEY (`blog_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_blog_2`
  FOREIGN KEY (`picture_id` )
  REFERENCES `tan`.`picture` (`picture_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`comments`   ADD CONSTRAINT `fk_comments_1`
  FOREIGN KEY (`object_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_comments_2`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`link`   ADD CONSTRAINT `fk_link_1`
  FOREIGN KEY (`link_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_link_2`
  FOREIGN KEY (`picture_id` )
  REFERENCES `tan`.`picture` (`picture_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`object`   ADD CONSTRAINT `fk_object_1`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`picture`   ADD CONSTRAINT `fk_picture_1`
  FOREIGN KEY (`picture_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`plus_minus`   ADD CONSTRAINT `fk_plus_minus_1`
  FOREIGN KEY (`object_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_plus_minus_2`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`poll`   ADD CONSTRAINT `fk_poll_1`
  FOREIGN KEY (`poll_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_poll_2`
  FOREIGN KEY (`picture_id` )
  REFERENCES `tan`.`picture` (`picture_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`poll_answer`   ADD CONSTRAINT `fk_poll_answer_1`
  FOREIGN KEY (`poll_id` )
  REFERENCES `tan`.`poll` (`poll_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`poll_vote`   ADD CONSTRAINT `fk_poll_vote_1`
  FOREIGN KEY (`answer_id` )
  REFERENCES `tan`.`poll_answer` (`answer_id` )
  ON DELETE CASCADE
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_poll_vote_2`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`profile`   ADD CONSTRAINT `fk_profile_1`
  FOREIGN KEY (`profile_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`tag_objects`   ADD CONSTRAINT `fk_tag_objects_1`
  FOREIGN KEY (`tag_id` )
  REFERENCES `tan`.`tags` (`tag_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_tag_objects_2`
  FOREIGN KEY (`object_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;



ALTER TABLE `tan`.`user_tokens`   ADD CONSTRAINT `fk_user_tokens_1`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`views`   ADD CONSTRAINT `fk_views_1`
  FOREIGN KEY (`object_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_views_2`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`user_admin`   ADD CONSTRAINT `fk_user_admin_1`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_user_admin_2`
  FOREIGN KEY (`admin_id` )
  REFERENCES `tan`.`admin` (`admin_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;


ALTER TABLE `tan`.`admin_log`   ADD CONSTRAINT `fk_admin_log_1`
  FOREIGN KEY (`admin_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_admin_log_2`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_admin_log_3`
  FOREIGN KEY (`object_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_admin_log_4`
  FOREIGN KEY (`comment_id` )
  REFERENCES `tan`.`comments` (`comment_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`video`   ADD CONSTRAINT `fk_video_1`
  FOREIGN KEY (`video_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_video_2`
  FOREIGN KEY (`picture_id` )
  REFERENCES `tan`.`picture` (`picture_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`forum`   ADD CONSTRAINT `fk_forum_1`
  FOREIGN KEY (`forum_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_forum_2`
  FOREIGN KEY (`picture_id` )
  REFERENCES `tan`.`picture` (`picture_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`cms`   ADD CONSTRAINT `fk_cms_1`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;

ALTER TABLE `tan`.`lotto`   ADD CONSTRAINT `fk_lotto_1`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;
