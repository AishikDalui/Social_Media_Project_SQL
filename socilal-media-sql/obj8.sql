WITH tag_stats AS (
  SELECT 
    t.tag_name,
    COUNT(DISTINCT pt.photo_id) AS total_posts_with_tag,
    COUNT(l.photo_id) AS total_likes_on_tagged_posts
  FROM tags t
  JOIN photo_tags pt ON t.id = pt.tag_id
  JOIN photos p ON pt.photo_id = p.id
  LEFT JOIN likes l ON l.photo_id = p.id
  GROUP BY t.tag_name
)

SELECT 
  tag_name,
  total_posts_with_tag,
  total_likes_on_tagged_posts,
  ROUND(total_likes_on_tagged_posts / total_posts_with_tag, 2) AS avg_likes_per_post
FROM tag_stats
ORDER BY avg_likes_per_post DESC

LIMIT 20;
