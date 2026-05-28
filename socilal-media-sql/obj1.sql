-- check how many user_name is null or not
-- id is primary key that's why we need to check username is null or created_at is null or not

SELECT 
SUM(
	CASE WHEN username IS NULL THEN 1 ELSE 0 END
) AS user_name_null_cnt,

SUM(
	CASE WHEN created_at IS NULL THEN 1 ELSE 0 END
) AS created_at_null_cnt
FROM users;


-- find duplicate photos are present or not

SELECT image_url, user_id, COUNT(*) AS total_cnt
FROM photos
GROUP BY image_url, user_id
HAVING COUNT(*) > 1;