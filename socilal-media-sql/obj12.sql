WITH hashtag_avg_likes AS (
    SELECT
        t.id AS tag_id,
        t.tag_name,
        AVG(COALESCE(l.like_count, 0)) AS avg_likes
    FROM tags t
    JOIN photo_tags pt
        ON t.id = pt.tag_id
    LEFT JOIN (
        SELECT
            photo_id,
            COUNT(*) AS like_count
        FROM likes
        GROUP BY photo_id
    ) l
        ON pt.photo_id = l.photo_id
    GROUP BY
        t.id,
        t.tag_name
),
ranked_hashtags AS (
    SELECT
        tag_name,
        ROUND(avg_likes, 2) AS avg_likes,
        DENSE_RANK() OVER (
            ORDER BY avg_likes DESC
        ) AS hashtag_rank
    FROM hashtag_avg_likes
)
SELECT
    tag_name,
    avg_likes
FROM ranked_hashtags
