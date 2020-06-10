SELECT s.`domain`, m.`directive`, u.`hash`, u.`consistent`, u.`ssl`, c.`certificate`, c.`key`
FROM `upstream` u
INNER JOIN `site` s ON  s.`id` =  u.`site_id`
INNER JOIN `method` m ON m.`id` = u.`method_id`
INNER JOIN `upstream_certificate` c ON c.`upstream_id` =  u.`id`
WHERE u.`site_id` = ?;