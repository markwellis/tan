ALTER TABLE `tan`.`object` CHANGE COLUMN `type` `type` ENUM('link','blog','picture','profile','poll', 'video') NOT NULL  ;

CREATE  TABLE IF NOT EXISTS `tan`.`video` (
  `video_id` BIGINT(20) NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `description` VARCHAR(1000) NOT NULL ,
  `picture_id` BIGINT(20) NOT NULL ,
  `url` VARCHAR(400) NOT NULL ,
  PRIMARY KEY (`video_id`) ,
  INDEX `fk_video_1` (`video_id` ASC) ,
  INDEX `fk_video_2` (`picture_id` ASC) ,
  CONSTRAINT `fk_video_10`
    FOREIGN KEY (`video_id` )
    REFERENCES `tan`.`object` (`object_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_video_20`
    FOREIGN KEY (`picture_id` )
    REFERENCES `tan`.`picture` (`picture_id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;
