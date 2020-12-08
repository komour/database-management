SELECT DISTINCT
  StudentId,
  StudentName,
  GroupId
FROM Students
WHERE StudentName = :StudentName;