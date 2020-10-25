SELECT
  StudentId,
  StudentName,
  GroupId
FROM Students s
WHERE EXISTS (SELECT
  StudentId,
  CourseId,
  Mark
FROM Marks m
WHERE m.Mark = :Mark
AND s.StudentId = m.StudentId
AND m.CourseId IN (SELECT
  CourseId
FROM Courses c
WHERE c.CourseName = :CourseName));