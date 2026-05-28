
  use ig_clone;
  
SELECT DISTINCT u.username
FROM follows f1
JOIN follows f2
    ON f1.follower_id = f2.followee_id
   AND f1.followee_id = f2.follower_id
   AND f1.created_at > f2.created_at
JOIN users u
    ON f1.follower_id = u.id;