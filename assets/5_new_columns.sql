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
