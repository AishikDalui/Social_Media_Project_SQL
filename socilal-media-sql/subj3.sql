WITH photo_engagement AS (
    SELECT
        p.user_id,
        p.id AS photo_id,
        COALESCE(l.like_count, 0) AS like_count,
        COALESCE(c.comment_count, 0) AS comment_count
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
user_summary AS (
    SELECT
        u.id AS user_id,
        u.username,
        COUNT(pe.photo_id) AS total_posts,
        COALESCE(SUM(pe.like_count), 0) AS total_likes_received,
        COALESCE(SUM(pe.comment_count), 0) AS total_comments_received
    FROM users u
    LEFT JOIN photo_engagement pe
        ON u.id = pe.user_id
    GROUP BY
        u.id,
        u.username
)
SELECT
    user_id,
    username,
    total_posts,
    total_likes_received,
    total_comments_received
FROM user_summary
WHERE total_posts = 0
   OR (
        total_posts > 0
        AND total_likes_received = 0
        AND total_comments_received = 0
      )
ORDER BY
    total_posts,
    username;