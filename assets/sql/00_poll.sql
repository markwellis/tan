SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

ALTER TABLE `tan`.`poll` ADD COLUMN `votes` BIGINT(20) NOT NULL DEFAULT 0  AFTER `end_date` ;


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

SELECT me.comment_id, me.comment, me.created, me.object_id, object.type, object.nsfw, link.title link_title, picture.title picture_title, blog.title blog_title, poll.title poll_title, video.title video_title, forum.title forum_title, user.username FROM comments me USE INDEX (recent) JOIN object object ON object.object_id = me.object_id LEFT JOIN link link ON link.link_id = me.object_id LEFT JOIN picture picture ON picture.picture_id = me.object_id LEFT JOIN blog blog ON blog.blog_id = me.object_id LEFT JOIN poll poll ON poll.poll_id = me.object_id LEFT JOIN video video ON video.video_id = me.object_id LEFT JOIN forum forum ON forum.forum_id = me.object_id JOIN user user ON user.user_id = me.user_id WHERE ( me.deleted = 'N' ) AND ( object.deleted = 'N' ) ORDER BY me.created DESC LIMIT 20;

DELIMITER $$

USE `tan`$$
DROP TRIGGER IF EXISTS `tan`.`increment_poll_answer_vote` $$


DELIMITER ;

DELIMITER $$

USE `tan`$$


Create Trigger increment_poll_votes
	AFTER INSERT ON poll_vote
	FOR EACH ROW
BEGIN

UPDATE poll_answer SET votes=votes+1 WHERE answer_id=NEW.answer_id;
UPDATE poll SET poll.votes=poll.votes+1 WHERE poll.poll_id=( SELECT poll_answer.poll_id FROM poll_answer WHERE poll_answer.answer_id = NEW.answer_id );

END$$


DELIMITER ;





SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
