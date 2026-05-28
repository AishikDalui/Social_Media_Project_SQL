-- distribution of user activity levels (e.g., number of posts, likes, comments) across the user base

SELECT u.id,
u.username,
coalesce(p.total_phoots, 0) AS total_posts,
coalesce(l.total_likes, 0) AS total_likes,
coalesce(c.total_comment, 0) AS total_comment
FROM users u 
LEFT JOIN (
	SELECT user_id, count(*) AS total_phoots
	FROM photos 
	GROUP BY user_id
)p ON u.id = p.user_id

LEFT JOIN (
	SELECT user_id, count(*) AS total_likes
	FROM likes
	GROUP BY user_id
) l ON u.id = l.user_id

LEFT JOIN(
	SELECT user_id, count(*) AS total_comment
	FROM comments
	GROUP BY user_id

)c ON u.id = c.user_id





