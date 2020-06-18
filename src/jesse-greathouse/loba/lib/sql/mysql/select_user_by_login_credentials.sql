SELECT u.*
FROM  `user` u 
LEFT JOIN `user_password` up ON up.`user_id` = u.`id`
LEFT JOIN `password` p ON up.`password_id` = p.`id`
WHERE 1 
AND u.`email` = ?
AND p.`password`= sha2(concat(?, p.`salt`), 224);