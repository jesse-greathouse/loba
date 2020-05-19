SELECT u.id as upstream_id, s.*
FROM `upstream` u
LEFT JOIN `site` s ON u.site_id = s.id
WHERE u.id IN (?);