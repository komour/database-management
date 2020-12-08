CREATE VIEW Losers AS
    SELECT StudentId, COUNT(StudentId) as DebtsCount
    FROM (Students NATURAL JOIN Plan) NATURAL LEFT JOIN Marks
    WHERE Mark < 3 OR Mark IS NULL
    GROUP BY StudentId