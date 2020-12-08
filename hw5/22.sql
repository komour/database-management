SELECT DISTINCT
  StudentId,
  StudentName,
  GroupName
FROM Students natural join Groups
WHERE StudentName = :StudentName;