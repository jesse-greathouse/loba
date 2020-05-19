SELECT u.id as upstream_id, m.*
FROM `upstream` u
LEFT JOIN `method` m ON u.method_id = m.id
WHERE u.id IN (?);