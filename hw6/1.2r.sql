SELECT
  StudentId,
  StudentName,
  GroupId
FROM Students s
WHERE EXISTS (SELECT
  s.GroupId,
  g.GroupName
FROM Groups g,
     Students
WHERE s.GroupId = g.GroupId
AND g.GroupName = :GroupName)