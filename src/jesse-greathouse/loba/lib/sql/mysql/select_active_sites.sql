SELECT *
FROM `site` s
INNER JOIN `upstream` u ON u.`site_id` = s.`id`
INNER JOIN (
	SELECT DISTINCT `upstream_id` FROM `upstream_server`
) us ON us.`upstream_id` = u.`id`
WHERE s.`active` = 1;