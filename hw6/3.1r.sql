SELECT DISTINCT
  s.StudentId,
  p.CourseId
FROM Students s,
     Plan p
WHERE p.GroupId = s.GroupId
UNION 
SELECT DISTINCT
  m.StudentId,
  m.CourseId
FROM Marks m;