WITH like_count AS (
  SELECT p.user_id, COUNT(*) AS total_likes
  FROM photos p
  JOIN likes l ON p.id = l.photo_id
  GROUP BY p.user_id
),
comment_count AS (
  SELECT p.user_id, COUNT(*) AS total_comments
  FROM photos p
  JOIN comments c ON p.id = c.photo_id
  GROUP BY p.user_id
)
SELECT 
  u.id AS user_id,
  u.username,
  COUNT(p.id) AS total_posts,
  COALESCE(like_count.total_likes, 0) AS total_likes,
  COALESCE(comment_count.total_comments, 0) AS total_comments,
  (COALESCE(like_count.total_likes, 0) + COALESCE(comment_count.total_comments, 0)) AS total_engagement,
  ROUND(
    (COALESCE(like_count.total_likes, 0) + COALESCE(comment_count.total_comments, 0)) / 
    NULLIF(COUNT(p.id), 0), 2
  ) AS avg_engagement_per_post,
  CASE
    WHEN ((COALESCE(like_count.total_likes, 0) + COALESCE(comment_count.total_comments, 0)) / NULLIF(COUNT(p.id), 0)) > 70 THEN 'Power Creator'
    WHEN ((COALESCE(like_count.total_likes, 0) + COALESCE(comment_count.total_comments, 0)) / NULLIF(COUNT(p.id), 0)) BETWEEN 40 AND 70 THEN 'Active Engager'
    WHEN ((COALESCE(like_count.total_likes, 0) + COALESCE(comment_count.total_comments, 0)) / NULLIF(COUNT(p.id), 0)) BETWEEN 1 AND 39 THEN 'Casual User'
    ELSE 'Dormant User'
  END AS user_segment
FROM users u
LEFT JOIN photos p ON p.user_id = u.id
LEFT JOIN like_count ON like_count.user_id = u.id
LEFT JOIN comment_count ON comment_count.user_id = u.id
GROUP BY u.id
ORDER BY avg_engagement_per_post DESC;
