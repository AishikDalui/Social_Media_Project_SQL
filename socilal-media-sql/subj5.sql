USE ig_clone;

WITH follower_stats AS (
    SELECT
        followee_id AS user_id,
        COUNT(*) AS follower_count
    FROM follows
    GROUP BY followee_id
),
like_stats AS (
    SELECT
        p.user_id,
        COUNT(*) AS total_likes
    FROM photos p
    JOIN likes l
        ON p.id = l.photo_id
    GROUP BY p.user_id
),
comment_stats AS (
    SELECT
        p.user_id,
        COUNT(*) AS total_comments
    FROM photos p
    JOIN comments c
        ON p.id = c.photo_id
    GROUP BY p.user_id
),
post_stats AS (
    SELECT
        user_id,
        COUNT(*) AS total_posts
    FROM photos
    GROUP BY user_id
),
influencer_metrics AS (
    SELECT
        u.id AS user_id,
        u.username,
        COALESCE(fs.follower_count, 0) AS follower_count,
        COALESCE(ps.total_posts, 0) AS total_posts,
        COALESCE(ls.total_likes, 0) AS total_likes,
        COALESCE(cs.total_comments, 0) AS total_comments,
        COALESCE(ls.total_likes, 0) +
        COALESCE(cs.total_comments, 0) AS total_engagement,
        ROUND(
            (
                COALESCE(ls.total_likes, 0) +
                COALESCE(cs.total_comments, 0)
            ) / NULLIF(COALESCE(ps.total_posts, 0), 0),
            2
        ) AS avg_engagement_per_post,
        ROUND(
            (
                (
                    COALESCE(ls.total_likes, 0) +
                    COALESCE(cs.total_comments, 0)
                ) / NULLIF(COALESCE(ps.total_posts, 0), 0)
            ) / NULLIF(COALESCE(fs.follower_count, 0), 0) * 100,
            2
        ) AS engagement_rate_pct
    FROM users u
    LEFT JOIN follower_stats fs
        ON u.id = fs.user_id
    LEFT JOIN post_stats ps
        ON u.id = ps.user_id
    LEFT JOIN like_stats ls
        ON u.id = ls.user_id
    LEFT JOIN comment_stats cs
        ON u.id = cs.user_id
)
SELECT
    user_id,
    username,
    follower_count,
    total_posts,
    total_likes,
    total_comments,
    total_engagement,
    avg_engagement_per_post,
    engagement_rate_pct,
    RANK() OVER (
        ORDER BY
            engagement_rate_pct DESC,
            total_engagement DESC,
            follower_count DESC
    ) AS influencer_rank
FROM influencer_metrics
WHERE total_posts > 0
ORDER BY influencer_rank
LIMIT 10;
