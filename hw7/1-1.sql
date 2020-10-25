DELETE FROM Students
WHERE StudentId not IN
    (SELECT StudentId
     FROM (Students NATURAL JOIN Plan) NATURAL JOIN Marks
     WHERE Mark < 60)