SELECT StudentName, CourseName FROM (SELECT
  s.StudentId,
  p.CourseId,
  s.StudentName,
  c.CourseName
FROM Students s,
     Courses c,
     Plan p
WHERE p.GroupId = s.GroupId
AND c.CourseId = p.CourseId
UNION 
SELECT
  m.StudentId,
  m.CourseId,
  s.StudentName,
  c.CourseName
FROM Students s,
     Courses c,
     Marks m
WHERE m.StudentId = s.StudentId
AND m.CourseId = c.CourseId) R;