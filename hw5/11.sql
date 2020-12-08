SELECT DISTINCT
  StudentId,
  StudentName,
  GroupId
FROM Students
WHERE StudentId = :StudentId;