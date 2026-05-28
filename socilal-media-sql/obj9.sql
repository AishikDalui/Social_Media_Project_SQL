SELECT 
  u.id AS user_id,
  u.username,
  COUNT(DISTINCT p.id) AS total_posts,
  COUNT(DISTINCT l.photo_id) AS total_likes_received,
  COUNT(DISTINCT c.id) AS total_comments_received,
  ROUND((COUNT(DISTINCT l.photo_id) + COUNT(DISTINCT c.id)) / COUNT(DISTINCT p.id), 2) AS avg_engagement_per_post
FROM users u
LEFT JOIN photos p ON p.user_id = u.id
LEFT JOIN likes l ON l.photo_id = p.id
LEFT JOIN comments c ON c.photo_id = p.id
GROUP BY u.id
HAVING COUNT(DISTINCT p.id) > 0
ORDER BY avg_engagement_per_post DESC;
