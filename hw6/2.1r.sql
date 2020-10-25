SELECT
  StudentId,
  StudentName,
  GroupName
FROM Students s,
     Groups g
WHERE EXISTS (SELECT
  s.GroupId,
  g.GroupName
FROM Groups,
     Students
WHERE s.GroupId = g.GroupId);