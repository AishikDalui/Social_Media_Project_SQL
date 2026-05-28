
use ig_clone;
WITH photo_engagement AS (
    SELECT
        p.id AS photo_id,
        dayname(p.created_dat) AS day_name,
        HOUR(p.created_dat) AS posting_hour,
        COALESCE(l.like_count, 0) +
        COALESCE(c.comment_count, 0) AS engagement
    FROM photos p
    LEFT JOIN (
        SELECT photo_id, COUNT(*) AS like_count
        FROM likes
        GROUP BY photo_id
    ) l ON p.id = l.photo_id
    LEFT JOIN (
        SELECT photo_id, COUNT(*) AS comment_count
        FROM comments
        GROUP BY photo_id
    ) c ON p.id = c.photo_id
)
SELECT
	day_name,
    posting_hour,
    ROUND(AVG(engagement), 2) AS avg_engagement
FROM photo_engagement
GROUP BY posting_hour, day_name
ORDER BY avg_engagement DESC;
