SELECT `upstream_server`.`host`, `upstream_server`.`weight`, `upstream_server`.`backup`, `upstream_server`.`fail_timeout`,  `upstream_server`.`max_fails`
FROM `upstream_server`
INNER JOIN `upstream` ON `upstream`.`id` = `upstream_server`.`upstream_id`
INNER JOIN `site` ON  `site`.`id` = `upstream`.`site_id`
WHERE `upstream`.`site_id` = ?;