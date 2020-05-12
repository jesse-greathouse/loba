SELECT `site`.`domain`, `method`.`directive`, `upstream`.`hash`, `upstream`.`consistent`
FROM `upstream`
INNER JOIN `site` ON  `site`.`id` = `upstream`.`site_id`
INNER JOIN `method` ON `method`.`id` = `upstream`.`method_id`
WHERE `upstream`.`site_id` = ?;