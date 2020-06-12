CREATE TABLE IF NOT EXISTS `user_password` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `password_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `user_id_idx` (`user_id` ASC),
  INDEX `password_id_idx` (`password_id` ASC),
  UNIQUE INDEX `user_password_unique` (`user_id` ASC, `password_id` ASC),
  CONSTRAINT `fk_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `user` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_password_id`
    FOREIGN KEY (`password_id`)
    REFERENCES `password` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);