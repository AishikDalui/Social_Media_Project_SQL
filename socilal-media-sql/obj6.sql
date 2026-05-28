SELECT
    u.id AS user_id,
    u.username,
    SUM(COALESCE(l.like_count, 0)) AS total_likes,
    SUM(COALESCE(c.comment_count, 0)) AS total_comments,
    ROUND(
        AVG(
            COALESCE(l.like_count, 0) + COALESCE(c.comment_count, 0)
        ),
        2
    ) AS avg_engagement_rate_per_post
FROM users u
JOIN photos p
    ON u.id = p.user_id
LEFT JOIN (
    SELECT
        photo_id,
        COUNT(*) AS like_count
    FROM likes
    GROUP BY photo_id
) l
    ON p.id = l.photo_id
LEFT JOIN (
    SELECT
        photo_id,
        COUNT(*) AS comment_count
    FROM comments
    GROUP BY photo_id
) c
    ON p.id = c.photo_id
GROUP BY
    u.id,
    u.username
ORDER BY avg_engagement_rate_per_post DESC;