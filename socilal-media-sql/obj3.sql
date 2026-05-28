SELECT AVG(total_tages) AS avg_no_of_tags
FROM(
	SELECT p.id,
	COUNT(pt.tag_id) AS total_tages
	FROM photos p
	LEFT JOIN photo_tags pt
	ON p.id = pt.photo_id
	GROUP BY p.id
) rs