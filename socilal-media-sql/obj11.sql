SELECT
    u.id AS user_id,
    u.username,
    SUM(COALESCE(l.like_count, 0)) AS total_likes_received,
    SUM(COALESCE(c.comment_count, 0)) AS total_comments_received,
    SUM(
        COALESCE(l.like_count, 0) +
        COALESCE(c.comment_count, 0)
    ) AS total_engagement,
    DENSE_RANK() OVER (
        ORDER BY SUM(
            COALESCE(l.like_count, 0) +
            COALESCE(c.comment_count, 0)
        ) DESC
    ) AS engagement_rank
FROM users u
JOIN photos p
    ON u.id = p.user_id
LEFT JOIN (
    SELECT
        photo_id,
        COUNT(*) AS like_count
    FROM likes
    WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    GROUP BY photo_id
) l
    ON p.id = l.photo_id
LEFT JOIN (
    SELECT
        photo_id,
        COUNT(*) AS comment_count
    FROM comments
    WHERE created_at >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    GROUP BY photo_id
) c
    ON p.id = c.photo_id
GROUP BY
    u.id,
    u.username
ORDER BY engagement_rank, u.username;