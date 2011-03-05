ALTER TABLE `tan`.`blog` 
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
, DROP INDEX `v_user` ;