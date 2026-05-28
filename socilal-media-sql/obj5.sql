-- find out the followers 

SELECT u.id, u.username, COUNT(f.follower_id) AS followers_count
FROM users u
LEFT JOIN follows f ON f.followee_id = u.id
GROUP BY u.id
ORDER BY followers_count DESC
LIMIT 50;


-- find out the number of follwed users 

SELECT u.id, u.username, COUNT(f.followee_id) AS following_count
FROM users u
LEFT JOIN follows f ON f.follower_id = u.id
GROUP BY u.id
ORDER BY following_count DESC
LIMIT 100;


