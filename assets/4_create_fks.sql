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
