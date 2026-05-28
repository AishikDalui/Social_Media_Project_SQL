USE ig_clone;

WITH follower_stats AS (
    SELECT
        followee_id AS user_id,
        COUNT(*) AS total_followers
    FROM follows
    GROUP BY followee_id
),
photo_engagement AS (
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
user_metrics AS (
    SELECT
        user_id,
        COUNT(photo_id) AS total_posts,
        SUM(likes_received) AS total_likes,
        SUM(comments_received) AS total_comments,
        SUM(engagement_per_post) AS total_engagement,
        ROUND(AVG(engagement_per_post), 2) AS avg_engagement_per_post
    FROM photo_engagement
    GROUP BY user_id
)
SELECT
    u.id AS user_id,
    u.username,
    COALESCE(fs.total_followers, 0) AS follower_count,
    um.total_posts,
    um.total_likes,
    um.total_comments,
    um.total_engagement,
    um.avg_engagement_per_post,
    ROUND(
        (um.avg_engagement_per_post / NULLIF(fs.total_followers, 0)) * 100,
        2
    ) AS engagement_rate_pct,

    CASE
        -- High reach + strong engagement + consistent posting
        WHEN COALESCE(fs.total_followers, 0) >= 90
             AND um.total_posts >= 5
             AND um.avg_engagement_per_post >= 60
        THEN 'Potential Brand Ambassador'

        -- Good creators with strong engagement
        WHEN COALESCE(fs.total_followers, 0) >= 50
             AND um.total_posts >= 3
             AND um.avg_engagement_per_post >= 40
        THEN 'Influencer Candidate'

        -- Users with highly engaged audiences
        WHEN um.avg_engagement_per_post >= 50
        THEN 'High Engagement Creator'

        -- Active and consistent posters
        WHEN um.total_posts >= 5
             AND um.total_engagement >= 200
        THEN 'Active Creator'

        -- Good community participants
        WHEN um.total_posts >= 3
             AND um.total_engagement >= 100
        THEN 'Community Advocate'

        ELSE 'Regular User'
    END AS user_badge,

    RANK() OVER (
        ORDER BY
            CASE
                WHEN COALESCE(fs.total_followers, 0) = 0 THEN 0
                ELSE (um.avg_engagement_per_post / fs.total_followers) * 100
            END DESC,
            um.total_engagement DESC,
            COALESCE(fs.total_followers, 0) DESC
    ) AS ambassador_rank

FROM users u
JOIN user_metrics um
    ON u.id = um.user_id
LEFT JOIN follower_stats fs
    ON u.id = fs.user_id
ORDER BY ambassador_rank;