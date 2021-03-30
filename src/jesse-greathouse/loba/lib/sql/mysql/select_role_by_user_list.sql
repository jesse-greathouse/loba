SELECT r.name as role, ur.user_id
FROM `user_role` ur
LEFT JOIN `role` r ON r.id = ur.role_id
WHERE ur.user_id IN (?);