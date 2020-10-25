SELECT
  StudentId,
  StudentName,
  GroupName
FROM Students s,
     Groups g
WHERE s.GroupId = g.GroupId;