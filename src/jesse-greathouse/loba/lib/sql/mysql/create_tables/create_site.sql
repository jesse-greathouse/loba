CREATE TABLE IF NOT EXISTS `site` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `domain` VARCHAR(45) NOT NULL,
  `active` TINYINT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `domain_UNIQUE` (`domain` ASC),
  INDEX `domain_active` (`domain` ASC, `active` ASC));