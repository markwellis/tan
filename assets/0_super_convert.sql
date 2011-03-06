ALTER TABLE `tan`.`blog` ENGINE = InnoDB ;

ALTER TABLE `tan`.`comments` ENGINE = InnoDB ;

ALTER TABLE `tan`.`link` ENGINE = InnoDB ;

ALTER TABLE `tan`.`object` ENGINE = InnoDB ;

ALTER TABLE `tan`.`old_lookup` ENGINE = InnoDB ;

ALTER TABLE `tan`.`picture` ENGINE = InnoDB ;

ALTER TABLE `tan`.`plus_minus` ENGINE = InnoDB ;

ALTER TABLE `tan`.`poll` ENGINE = InnoDB ;

ALTER TABLE `tan`.`poll_answer` ENGINE = InnoDB ;

ALTER TABLE `tan`.`poll_vote` ENGINE = InnoDB ;

ALTER TABLE `tan`.`profile` ENGINE = InnoDB ;

ALTER TABLE `tan`.`tag_objects` ENGINE = InnoDB ;

ALTER TABLE `tan`.`tags` ENGINE = InnoDB ;

ALTER TABLE `tan`.`user` ENGINE = InnoDB ;

ALTER TABLE `tan`.`user_tokens` ENGINE = InnoDB ;

ALTER TABLE `tan`.`views` ENGINE = InnoDB ;ALTER TABLE `tan`.`blog` 
DROP INDEX `b_image` 
, DROP INDEX `b_object` ;

ALTER TABLE `tan`.`comments` 
DROP INDEX `c_object` 
, DROP INDEX `c_user` ;

ALTER TABLE `tan`.`link` 
DROP INDEX `l_object` 
, DROP INDEX `l_image` ;

ALTER TABLE `tan`.`object` 
DROP INDEX `o_user` ;

ALTER TABLE `tan`.`old_lookup` 
DROP INDEX `ol_object` ;

ALTER TABLE `tan`.`picture` 
DROP INDEX `p_object` ;

ALTER TABLE `tan`.`plus_minus` 
DROP INDEX `fk_plus_minus_1` 
, DROP INDEX `object_id` ;

ALTER TABLE `tan`.`poll` 
DROP INDEX `fk_poll_2` 
, DROP INDEX `fk_poll_1` 
, DROP INDEX `b_object` 
, DROP INDEX `b_image` ;

ALTER TABLE `tan`.`poll_answer` 
DROP INDEX `fk_poll_answer_1` 
, DROP INDEX `ans` ;

ALTER TABLE `tan`.`poll_vote` 
DROP INDEX `fk_poll_vote_2` 
, DROP INDEX `fk_poll_vote_1` ;

ALTER TABLE `tan`.`profile` 
DROP INDEX `b_object` ;

ALTER TABLE `tan`.`tag_objects` 
DROP INDEX `t_object` 
, DROP INDEX `tags` ;

ALTER TABLE `tan`.`user_tokens` 
DROP INDEX `ut_user` ;

ALTER TABLE `tan`.`views` 
DROP INDEX `v_object` 
, DROP INDEX `v_user` ;UPDATE link SET picture_id = 53016 WHERE picture_id = 0 OR picture_id = 1;

UPDATE blog SET picture_id = 53016 WHERE picture_id = 0 OR picture_id = 1;

DELETE comments.* FROM comments LEFT JOIN object ON ( comments.object_id = object.object_id ) WHERE comments.object_id IS NOT NULL AND object.object_id IS NULL;

DELETE FROM old_lookup WHERE type = 'user';
ALTER TABLE `tan`.`old_lookup` CHANGE COLUMN `type` `type` ENUM('link','blog','picture') NOT NULL;

DELETE picture.* FROM picture LEFT JOIN object ON ( picture.picture_id = object.object_id ) WHERE picture.picture_id IS NOT NULL AND object.object_id IS NULL;

DELETE plus_minus.* FROM plus_minus LEFT JOIN object ON ( plus_minus.object_id = object.object_id ) WHERE plus_minus.object_id IS NOT NULL AND object.object_id IS NULL;

DELETE profile.* FROM profile LEFT JOIN object ON ( profile.profile_id = object.object_id ) WHERE profile.profile_id IS NOT NULL AND object.object_id IS NULL;

DELETE tag_objects.* FROM tag_objects LEFT JOIN object ON ( tag_objects.object_id = object.object_id ) WHERE tag_objects.object_id IS NOT NULL AND object.object_id IS NULL;

UPDATE views SET user_id = NULL WHERE user_id = 0;
DELETE views.* FROM views LEFT JOIN object ON ( views.object_id = object.object_id ) WHERE views.object_id IS NOT NULL AND object.object_id IS NULL;
ALTER TABLE `tan`.`blog` 
  ADD CONSTRAINT `fk_blog_1`
  FOREIGN KEY (`blog_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_blog_2`
  FOREIGN KEY (`picture_id` )
  REFERENCES `tan`.`picture` (`picture_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_blog_1` (`blog_id` ASC) 
, ADD INDEX `fk_blog_2` (`picture_id` ASC) ;
SHOW WARNINGS;

ALTER TABLE `tan`.`comments` 
  ADD CONSTRAINT `fk_comments_1`
  FOREIGN KEY (`object_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_comments_2`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_comments_1` (`object_id` ASC) 
, ADD INDEX `fk_comments_2` (`user_id` ASC) ;
SHOW WARNINGS;

ALTER TABLE `tan`.`link` 
  ADD CONSTRAINT `fk_link_1`
  FOREIGN KEY (`link_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_link_2`
  FOREIGN KEY (`picture_id` )
  REFERENCES `tan`.`picture` (`picture_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_link_1` (`link_id` ASC) 
, ADD INDEX `fk_link_2` (`picture_id` ASC) ;
SHOW WARNINGS;

ALTER TABLE `tan`.`object` 
  ADD CONSTRAINT `fk_object_1`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_object_1` (`user_id` ASC) ;
SHOW WARNINGS;

ALTER TABLE `tan`.`old_lookup` 
  ADD CONSTRAINT `fk_old_lookup_1`
  FOREIGN KEY (`new_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_old_lookup_1` (`new_id` ASC) ;
SHOW WARNINGS;

ALTER TABLE `tan`.`picture` 
  ADD CONSTRAINT `fk_picture_1`
  FOREIGN KEY (`picture_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_picture_1` (`picture_id` ASC) ;
SHOW WARNINGS;

ALTER TABLE `tan`.`plus_minus` 
  ADD CONSTRAINT `fk_plus_minus_1`
  FOREIGN KEY (`object_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_plus_minus_2`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_plus_minus_1` (`object_id` ASC) 
, ADD INDEX `fk_plus_minus_2` (`user_id` ASC) ;
SHOW WARNINGS;

ALTER TABLE `tan`.`poll` 
  ADD CONSTRAINT `fk_poll_1`
  FOREIGN KEY (`poll_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_poll_2`
  FOREIGN KEY (`picture_id` )
  REFERENCES `tan`.`picture` (`picture_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_poll_1` (`poll_id` ASC) 
, ADD INDEX `fk_poll_2` (`picture_id` ASC) ;
SHOW WARNINGS;

ALTER TABLE `tan`.`poll_answer` 
  ADD CONSTRAINT `fk_poll_answer_1`
  FOREIGN KEY (`poll_id` )
  REFERENCES `tan`.`poll` (`poll_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_poll_answer_1` (`poll_id` ASC) ;
SHOW WARNINGS;

ALTER TABLE `tan`.`poll_vote` 
  ADD CONSTRAINT `fk_poll_vote_1`
  FOREIGN KEY (`answer_id` )
  REFERENCES `tan`.`poll_answer` (`answer_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_poll_vote_2`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_poll_vote_1` (`answer_id` ASC) 
, ADD INDEX `fk_poll_vote_2` (`user_id` ASC) ;
SHOW WARNINGS;

ALTER TABLE `tan`.`profile` 
  ADD CONSTRAINT `fk_profile_1`
  FOREIGN KEY (`profile_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_profile_1` (`profile_id` ASC) ;
SHOW WARNINGS;

ALTER TABLE `tan`.`tag_objects` 
  ADD CONSTRAINT `fk_tag_objects_1`
  FOREIGN KEY (`tag_id` )
  REFERENCES `tan`.`tags` (`tag_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_tag_objects_2`
  FOREIGN KEY (`object_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_tag_objects_1` (`tag_id` ASC) 
, ADD INDEX `fk_tag_objects_2` (`object_id` ASC) ;
SHOW WARNINGS;

ALTER TABLE `tan`.`user_tokens` 
  ADD CONSTRAINT `fk_user_tokens_1`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_user_tokens_1` (`user_id` ASC) ;
SHOW WARNINGS;

ALTER TABLE `tan`.`views` 
  ADD CONSTRAINT `fk_views_1`
  FOREIGN KEY (`object_id` )
  REFERENCES `tan`.`object` (`object_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION, 
  ADD CONSTRAINT `fk_views_2`
  FOREIGN KEY (`user_id` )
  REFERENCES `tan`.`user` (`user_id` )
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
, ADD INDEX `fk_views_1` (`object_id` ASC) 
, ADD INDEX `fk_views_2` (`user_id` ASC) ;
SHOW WARNINGS;
ALTER TABLE `tan`.`object` ADD COLUMN `views` BIGINT(20) NOT NULL DEFAULT 0  AFTER `NSFW` , ADD COLUMN `plus` BIGINT(20) NOT NULL DEFAULT 0  AFTER `views` , ADD COLUMN `minus` BIGINT(20) NOT NULL DEFAULT 0  AFTER `plus` , ADD COLUMN `comments` BIGINT(20) NOT NULL DEFAULT 0  AFTER `minus` ;

ALTER TABLE `tan`.`poll_answer` ADD COLUMN `votes` BIGINT(20) NOT NULL DEFAULT 0  AFTER `answer` ;

UPDATE object SET views = ( SELECT COUNT(*) FROM views WHERE views.object_id = object.object_id AND type='internal' );

UPDATE object SET plus = ( SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = object.object_id AND type='plus' );

UPDATE object SET minus = ( SELECT COUNT(*) FROM plus_minus WHERE plus_minus.object_id = object.object_id AND type='minus' );

UPDATE object SET comments = ( SELECT COUNT(*) FROM comments WHERE comments.object_id = object.object_id AND deleted='N' );

UPDATE poll_answer SET votes = ( SELECT COUNT(*) FROM poll_vote WHERE poll_answer.answer_id = poll_vote.answer_id );

ALTER TABLE `tan`.`comments` 
ADD INDEX `recent` (`deleted` ASC, `created` ASC, `object_id` ASC) 
, DROP INDEX `object` 
, DROP INDEX `created` 
, DROP INDEX `deleted` ;
DELIMITER $$

USE `tan`$$


Create Trigger increment_object_comments
	AFTER INSERT ON comments
	FOR EACH ROW
BEGIN

UPDATE object SET comments=comments+1 WHERE object_id=NEW.object_id;

END$$


DELIMITER ;


DELIMITER $$

USE `tan`$$


Create Trigger decrement_object_comments
	AFTER UPDATE ON comments
	FOR EACH ROW
BEGIN

IF NEW.deleted = 'Y' THEN
	UPDATE object SET comments=comments-1 WHERE object_id=NEW.object_id;
END IF;

END$$


DELIMITER ;


DELIMITER $$

USE `tan`$$


Create Trigger increment_object_plus_minus
	AFTER INSERT ON plus_minus
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


Create Trigger decrement_object_plus_minus
	AFTER DELETE ON plus_minus
	FOR EACH ROW
BEGIN

IF OLD.type = 'plus' THEN
	UPDATE object SET plus=plus-1 WHERE object_id=OLD.object_id;
ELSEIF OLD.type = 'minus' THEN
	UPDATE object SET minus=minus-1 WHERE object_id=OLD.object_id;
END IF;

END$$


DELIMITER ;


DELIMITER $$

USE `tan`$$


Create Trigger increment_poll_answer_vote
	AFTER INSERT ON poll_vote
	FOR EACH ROW
BEGIN

UPDATE poll_answer SET votes=votes+1 WHERE answer_id=NEW.answer_id;

END$$


DELIMITER ;


DELIMITER $$

USE `tan`$$


Create Trigger increment_object_views
	AFTER INSERT ON views
	FOR EACH ROW
BEGIN

UPDATE object SET views=views+1 WHERE object_id=NEW.object_id;

END$$


DELIMITER ;