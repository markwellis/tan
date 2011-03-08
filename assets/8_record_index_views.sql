SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

ALTER TABLE `tan`.`views` DROP FOREIGN KEY `fk_views_1` ;

ALTER TABLE `tan`.`views` CHANGE COLUMN `object_id` `object_id` BIGINT(20) NULL DEFAULT NULL  , 
  ADD CONSTRAINT `fk_views_1`
  FOREIGN KEY (`object_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION;


-- -----------------------------------------------------
-- Placeholder table for view `tan`.`recent_comments`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `tan`.`recent_comments` (`comment_id` INT, `comment` INT, `created` INT, `object_id` INT, `type` INT, `nsfw` INT, `link_title` INT, `picture_title` INT, `blog_title` INT, `poll_title` INT, `username` INT);


USE `tan`;

-- -----------------------------------------------------
-- View `tan`.`recent_comments`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tan`.`recent_comments`;
USE `tan`;
CREATE  OR REPLACE VIEW `tan`.`recent_comments` AS

SELECT me.comment_id, me.comment, me.created, me.object_id, object.type, object.nsfw, link.title link_title, picture.title picture_title, blog.title blog_title, poll.title poll_title, user.username FROM comments me USE INDEX (recent) JOIN object object ON object.object_id = me.object_id LEFT JOIN link link ON link.link_id = me.object_id LEFT JOIN picture picture ON picture.picture_id = me.object_id LEFT JOIN blog blog ON blog.blog_id = me.object_id LEFT JOIN poll poll ON poll.poll_id = me.object_id JOIN user user ON user.user_id = me.user_id WHERE ( me.deleted = 'N' ) ORDER BY me.created DESC LIMIT 20;

DELIMITER $$

USE `tan`$$
DROP TRIGGER IF EXISTS `tan`.`increment_object_views` $$


DELIMITER ;


DELIMITER $$

USE `tan`$$


Create Trigger increment_object_views
	AFTER INSERT ON views
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
