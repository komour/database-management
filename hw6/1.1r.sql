SELECT
  StudentId,
  StudentName,
  GroupId
FROM Students s
WHERE s.StudentName = :StudentName