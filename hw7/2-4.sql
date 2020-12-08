MERGE INTO LoserT
USING (
  SELECT StudentId, Mark, NewMark
  FROM Students
    NATURAL JOIN Plan
    NATURAL LEFT JOIN Marks
    NATURAL JOIN NewPoints
) MarksUpdates
ON LoserT.StudentId = MarksUpdates.StudentId
WHEN MATCHED
  AND MarksUpdates.Mark >= 60
  AND MarksUpdates.Mark + MarksUpdates.NewMark < 60
  THEN UPDATE SET DebtAmount = LoserT.DebtAmount + 1
WHEN MATCHED
  AND MarksUpdates.Mark < 60
  AND MarksUpdates.Mark + MarksUpdates.NewMark >= 60
  AND LoserT.DebtAmount > 1
  THEN UPDATE SET DebtAmount = LoserT.DebtAmount - 1
WHEN MATCHED
  AND MarksUpdates.Mark < 60
  AND MarksUpdates.Mark + MarksUpdates.NewMark >= 60
  AND LoserT.DebtAmount = 1
  THEN DELETE
WHEN NOT MATCHED
  AND MarksUpdates.Mark + MarksUpdates.NewMark < 60
  THEN INSERT (StudentId, DebtAmount) VALUES (MarksUpdates.StudentId, 1);