 SELECT
  u.id, u.username,
  COALESCE(SUM(pl.likes_count),0) AS likes_received,
  COALESCE(SUM(pc.comments_count),0) AS comments_received,
  COALESCE(SUM(pl.likes_count) + SUM(pc.comments_count),0) AS total_engagement,
  ROUND(COALESCE(SUM(pl.likes_count) + SUM(pc.comments_count),0) / NULLIF(COUNT(p.id),0), 2) AS engagement_per_post
FROM users u
LEFT JOIN photos p ON p.user_id = u.id
LEFT JOIN (
  SELECT photo_id, COUNT(*) AS likes_count FROM likes GROUP BY photo_id
) pl ON pl.photo_id = p.id
LEFT JOIN (
  SELECT photo_id, COUNT(*) AS comments_count FROM comments GROUP BY photo_id
) pc ON pc.photo_id = p.id
GROUP BY u.id,u.username
ORDER BY engagement_per_post DESC
LIMIT 5;
