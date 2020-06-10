CREATE TABLE IF NOT EXISTS `upstream_certificate` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `upstream_id` INT NOT NULL,
  `key` LONGTEXT NULL DEFAULT NULL,
  `certificate` LONGTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_upstream_idx` (`upstream_id` ASC),
  UNIQUE INDEX `upstream_id_UNIQUE` (`upstream_id` ASC),
  CONSTRAINT `fk_upstream`
    FOREIGN KEY (`upstream_id`)
    REFERENCES `upstream` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);