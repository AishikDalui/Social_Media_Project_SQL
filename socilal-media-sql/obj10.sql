SELECT
  u.id, u.username,
  COALESCE(posts_count,0) AS posts_count,
  COALESCE(likes_received,0) AS likes_received,
  COALESCE(comments_received,0) AS comments_received,
  COALESCE(tags_count,0) AS tags_count
FROM users u
LEFT JOIN (
  SELECT user_id, COUNT(*) AS posts_count FROM photos GROUP BY user_id
) p ON p.user_id = u.id
LEFT JOIN (
  SELECT ph.user_id, COUNT(*) AS likes_received
  FROM photos ph
  JOIN likes l ON l.photo_id = ph.id
  GROUP BY ph.user_id
) lr ON lr.user_id = u.id
LEFT JOIN (
  SELECT ph.user_id, COUNT(*) AS comments_received
  FROM photos ph JOIN comments c ON c.photo_id = ph.id
  GROUP BY ph.user_id
) cr ON cr.user_id = u.id
LEFT JOIN (
  SELECT ph.user_id, COUNT(*) AS tags_count
  FROM photos ph JOIN photo_tags pt ON pt.photo_id = ph.id
  GROUP BY ph.user_id
) tr ON tr.user_id = u.id;
