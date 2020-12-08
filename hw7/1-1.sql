DELETE FROM Students
WHERE StudentId not IN
    (SELECT StudentId
     FROM (Students NATURAL JOIN Plan) NATURAL LEFT JOIN Marks
     WHERE Mark < 3 OR Mark is NULL)