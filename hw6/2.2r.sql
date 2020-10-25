SELECT
  StudentId,
  StudentName,
  GroupName
FROM Students s,
     Groups g
WHERE g.GroupId = s.GroupId
AND NOT EXISTS (SELECT
  m.CourseId,
  m.StudentId,
  c.CourseId,
  c.CourseName
FROM Courses c,
     Marks m
WHERE c.CourseId = m.CourseId
AND s.StudentId = m.StudentId
AND c.CourseName = :CourseName);