UPDATE link SET picture_id = 53016 WHERE picture_id = 0 OR picture_id = 1;

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
