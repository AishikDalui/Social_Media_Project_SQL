use ig_clone;

SELECT u.id, 
u.username,
COUNT(*) OVER () AS subtotal_count
FROM users u 
LEFT JOIN likes l 
ON u.id = l.user_id
WHERE l.user_id is NULL;