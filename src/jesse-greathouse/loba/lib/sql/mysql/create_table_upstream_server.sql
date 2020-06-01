CREATE TABLE IF NOT EXISTS `upstream_server` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `host` VARCHAR(255) NULL,
  `backup` TINYINT NOT NULL DEFAULT 0,
  `upstream_id` INT NOT NULL,
  `weight` VARCHAR(4) NULL,
  `fail_timeout` VARCHAR(4) NULL,
  `max_fails`VARCHAR(4) NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_upstream_id_idx` (`upstream_id` ASC),
  INDEX `weight` (`weight` DESC),
  CONSTRAINT `fk_upstream_id`
    FOREIGN KEY (`upstream_id`)
    REFERENCES `upstream` (`id`)
    ON DELETE CASCADE
    ON UPDATE NO ACTION);