SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';

DELIMITER $$
USE `tan`$$

Create Trigger increment_object_comments
	AFTER INSERT ON comments
	FOR EACH ROW
BEGIN

UPDATE object SET comments=comments+1 WHERE object_id=NEW.object_id;

END$$

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

IF NEW.object_id IS NOT NULL THEN
	UPDATE object SET views=views+1 WHERE object_id=NEW.object_id;
END IF;

END$$


DELIMITER ;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
