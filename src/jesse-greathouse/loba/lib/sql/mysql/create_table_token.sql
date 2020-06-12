CREATE TABLE IF NOT EXISTS `token` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `token` VARCHAR(224) NOT NULL,
  `ttl` INT(8) NOT NULL DEFAULT 86400,
  `provider` VARCHAR(45) NULL DEFAULT NULL,
  `created_at` INT(8) NULL DEFAULT NULL,
  `user_id` INT(11) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `token_user_id_idx` (`user_id` ASC),
  UNIQUE INDEX `token_uniq` (`token` ASC),
  INDEX `ttl_idx` (`ttl` ASC),
  CONSTRAINT `fk_token_user_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `user` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);