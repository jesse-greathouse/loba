CREATE TABLE IF NOT EXISTS `method` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NOT NULL,
  `directive` VARCHAR(45) NULL,
  `description` LONGTEXT NULL DEFAULT NULL ,
  `url` VARCHAR(255) NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `directive_UNIQUE` (`directive` ASC));