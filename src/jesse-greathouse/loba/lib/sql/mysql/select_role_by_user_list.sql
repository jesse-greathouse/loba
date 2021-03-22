SELECT r.name as role, u.id as user_id
FROM `user` u
LEFT JOIN  `user_role` ur ON ur.user_id = u.id
LEFT JOIN `role` r ON r.id = ur.role_id
WHERE u.id IN (?);