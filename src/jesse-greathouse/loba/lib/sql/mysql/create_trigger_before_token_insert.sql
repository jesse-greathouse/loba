DROP TRIGGER IF EXISTS `token_BEFORE_INSERT`;

CREATE TRIGGER `token_BEFORE_INSERT` BEFORE INSERT ON `token` FOR EACH ROW
BEGIN
	IF (new.`created_at` IS NULL) THEN
        SET new.`created_at` = UNIX_TIMESTAMP();
	END IF;
    
	IF (new.`provider` IS NULL) THEN
        SET new.`provider` = 'LOBA';
	END IF;
END