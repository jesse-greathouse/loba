SELECT s.* 
FROM `upstream` u
LEFT JOIN `site` s ON s.id = u.site_id
WHERE u.id = ?