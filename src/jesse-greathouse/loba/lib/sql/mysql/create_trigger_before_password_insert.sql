DROP TRIGGER IF EXISTS `password_BEFORE_INSERT`;

DELIMITER $$
CREATE DEFINER=CURRENT_USER TRIGGER `password_BEFORE_INSERT` BEFORE INSERT ON `password` FOR EACH ROW BEGIN
  SET new.`salt` = sha2(rand(), 224);
  SET new.`password` = sha2(concat(new.`password`, new.`salt`), 224);
END$$
DELIMITER ;