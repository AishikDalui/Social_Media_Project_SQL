WITH photo_engagement AS (
    SELECT
        p.user_id,
        p.id AS photo_id,
        COALESCE(l.like_count, 0) AS likes_received,
        COALESCE(c.comment_count, 0) AS comments_received,
        COALESCE(l.like_count, 0) + COALESCE(c.comment_count, 0) AS engagement_per_post
    FROM photos p
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
),
user_engagement AS (
    SELECT
        user_id,
        COUNT(photo_id) AS total_posts,
        SUM(likes_received) AS total_likes_received,
        SUM(comments_received) AS total_comments_received,
        SUM(engagement_per_post) AS total_engagement,
        ROUND(AVG(engagement_per_post), 2) AS avg_engagement_per_post
    FROM photo_engagement
    GROUP BY user_id
    HAVING COUNT(photo_id) >= 3      -- optional minimum post threshold
),
ranked_users AS (
    SELECT
        u.id AS user_id,
        u.username,
        ue.total_posts,
        ue.total_likes_received,
        ue.total_comments_received,
        ue.total_engagement,
        ue.avg_engagement_per_post,
        DENSE_RANK() OVER (
            ORDER BY
                ue.total_engagement DESC,
                ue.avg_engagement_per_post DESC
        ) AS engagement_rank
    FROM user_engagement ue
    JOIN users u
        ON ue.user_id = u.id
)
SELECT
    user_id,
    username,
    total_posts,
    total_likes_received,
    total_comments_received,
    total_engagement,
    avg_engagement_per_post,
    engagement_rank
FROM ranked_users
WHERE engagement_rank <= 5
ORDER BY engagement_rank, username;