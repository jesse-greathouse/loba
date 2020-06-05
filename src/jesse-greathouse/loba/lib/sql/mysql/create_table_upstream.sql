CREATE TABLE IF NOT EXISTS `upstream` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `site_id` INT NOT NULL,
  `method_id` INT NOT NULL,
  `hash` VARCHAR(255) NULL,
  `consistent` TINYINT NOT NULL DEFAULT 0,
  `ssl` TINYINT(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  INDEX `id_site_id` (`site_id` ASC),
  INDEX `id_method_id` (`method_id` ASC),
  UNIQUE INDEX `site_id_UNIQUE` (`site_id` ASC),
  CONSTRAINT `fk_site_id`
    FOREIGN KEY (`site_id`)
    REFERENCES `site` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_method_id`
    FOREIGN KEY (`method_id`)
    REFERENCES `method` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);