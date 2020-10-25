SELECT
  g.GroupId,
  c.CourseId
FROM Courses c,
     Groups g
WHERE NOT EXISTS (SELECT
  s.StudentId,
  s.GroupId
FROM Students s
WHERE s.GroupId = g.GroupId
AND NOT EXISTS (SELECT
  m.StudentId,
  m.CourseId
FROM Marks m
WHERE m.StudentId = s.StudentId
AND c.CourseId = m.CourseId));