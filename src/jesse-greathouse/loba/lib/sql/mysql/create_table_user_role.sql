CREATE TABLE IF NOT EXISTS `user_role` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `role_id` INT NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk user_id_idx` (`user_id` ASC),
  INDEX `fk role_id_idx` (`role_id` ASC),
  UNIQUE INDEX `user_role_unique` (`user_id` ASC, `role_id` ASC),
  CONSTRAINT `fk user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `user` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk role_id`
    FOREIGN KEY (`role_id`)
    REFERENCES `role` (`id`)
    ON DELETE CASCADE
    ON UPDATE CASCADE);