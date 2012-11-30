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
