#triggers are shit, let's remove them
DROP TRIGGER IF EXISTS increment_object_plus_minus;
DROP TRIGGER IF EXISTS decrement_object_plus_minus;

#delete the fks, because the names suck and this messes up dbicdump
ALTER TABLE plus_minus DROP FOREIGN KEY fk_plus_minus_1;
ALTER TABLE plus_minus DROP FOREIGN KEY fk_plus_minus_2;

#delete duplicates (back in the day you could tins and tan things, but not anymore, so remove the duplicates)
START TRANSACTION;
    CREATE TEMPORARY TABLE safe_plus_minus (
        `plus_minus_id` mediumint(8) unsigned NOT NULL,
        PRIMARY KEY (`plus_minus_id`)
    );

    INSERT INTO safe_plus_minus (plus_minus_id) SELECT MIN(plus_minus_id) FROM plus_minus GROUP BY object_id, user_id;
    DELETE FROM plus_minus WHERE plus_minus_id NOT IN ( SELECT * FROM safe_plus_minus );

    DROP TEMPORARY TABLE safe_plus_minus;
COMMIT;

#remove index, we'll readd it as a unique
ALTER TABLE plus_minus DROP INDEX object_type;
ALTER TABLE plus_minus ADD UNIQUE INDEX user_object_type (user_id, object_id, type);

ALTER TABLE plus_minus ADD COLUMN comment_id mediumint(8) unsigned;
ALTER TABLE plus_minus ADD UNIQUE INDEX user_comment_type (user_id, comment_id, type);

#readd the foreign keys, but this time with better names
ALTER TABLE plus_minus ADD CONSTRAINT plus_minus_user FOREIGN KEY (user_id) REFERENCES user (user_id);
ALTER TABLE plus_minus ADD CONSTRAINT plus_minus_object FOREIGN KEY (object_id) REFERENCES object (object_id);
ALTER TABLE plus_minus ADD CONSTRAINT plus_minus_comment FOREIGN KEY (comment_id) REFERENCES comments (comment_id);

ALTER TABLE plus_minus ADD COLUMN created TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00';

#rename PK
ALTER TABLE plus_minus CHANGE plus_minus_id id mediumint(8) unsigned NOT NULL AUTO_INCREMENT;
