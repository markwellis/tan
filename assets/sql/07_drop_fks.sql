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
