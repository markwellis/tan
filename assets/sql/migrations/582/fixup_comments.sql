#triggers are shit, let's remove them
DROP TRIGGER IF EXISTS increment_object_comments;
DROP TRIGGER IF EXISTS decrement_object_comments;

#delete the fks, because the names suck and this messes up dbicdump
ALTER TABLE comments DROP FOREIGN KEY fk_comments_1;
ALTER TABLE comments DROP FOREIGN KEY fk_comments_2;
ALTER TABLE comments DROP KEY fk_comments_1;
ALTER TABLE comments DROP KEY fk_comments_2;

ALTER TABLE comments CHANGE created created TIMESTAMP NOT NULL DEFAULT '0000-00-00 00:00:00';
ALTER TABLE comments ADD COLUMN updated TIMESTAMP DEFAULT now() ON UPDATE now();

ALTER TABLE comments ADD COLUMN plus INTEGER NOT NULL DEFAULT 0;
ALTER TABLE comments ADD COLUMN minus INTEGER NOT NULL DEFAULT 0;

#readd the foreign keys, but this time with better names
ALTER TABLE comments ADD CONSTRAINT comments_user FOREIGN KEY (user_id) REFERENCES user (user_id);
ALTER TABLE comments ADD CONSTRAINT comments_object FOREIGN KEY (object_id) REFERENCES object (object_id);

#drop this fk so we can rename the column it references
ALTER TABLE admin_log DROP FOREIGN KEY fk_admin_log_4;
ALTER TABLE admin_log DROP KEY fk_admin_log_4;

#drop this view because it references the old pk, and it's shit
DROP VIEW IF EXISTS recent_comments;

#rename PK
ALTER TABLE comments CHANGE comment_id id mediumint(8) unsigned NOT NULL AUTO_INCREMENT;

#read it (better name as well)
ALTER TABLE admin_log ADD CONSTRAINT admin_log_comment FOREIGN KEY (comment_id) REFERENCES comments (id);

ALTER TABLE comments DROP KEY recent;
ALTER TABLE comments ADD INDEX recent (created DESC, object_id, user_id, deleted);

OPTIMIZE TABLE comments;
