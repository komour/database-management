DELETE FROM Students 
WHERE StudentId IN (SELECT StudentId
	FROM (Students NATURAL JOIN Plan) NATURAL LEFT JOIN Marks
	WHERE Mark < 60 OR Mark is NULL
	GROUP BY StudentId
    HAVING COUNT(StudentId) > 3)