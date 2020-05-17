CREATE TABLE IF NOT EXISTS `upstream_server` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `host` VARCHAR(255) NULL,
  `backup` TINYINT NOT NULL DEFAULT 0,
  `upstream_id` INT NOT NULL,
  `weight` TINYINT NULL,
  `fail_timeout` TINYINT NULL,
  `max_fails` TINYINT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_upstream_id_idx` (`upstream_id` ASC),
  INDEX `weight` (`weight` DESC),
  CONSTRAINT `fk_upstream_id`
    FOREIGN KEY (`upstream_id`)
    REFERENCES `upstream` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);