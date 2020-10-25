CREATE VIEW Losers AS
    SELECT StudentId, COUNT(StudentId)
    FROM (Students NATURAL JOIN Plan) NATURAL JOIN Marks
    WHERE Mark < 60
    GROUP BY StudentId