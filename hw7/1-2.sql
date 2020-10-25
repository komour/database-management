DELETE FROM Students
WHERE StudentId IN (SELECT StudentId
     FROM Students s
     WHERE (SELECT COUNT(Mark)
     		FROM (Students NATURAL JOIN Plan) NATURAL JOIN Marks AS J
     		WHERE Mark < 60
     		AND J.StudentId = s.StudentId) >= 3)