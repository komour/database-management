SELECT DISTINCT
  StudentId,
  StudentName,
  GroupName
FROM Students s,
     Groups g,
     Plan p,
	 Courses co
WHERE g.GroupId = s.GroupId
AND p.GroupId = s.GroupId
AND p.CourseId = co.CourseId
AND co.CourseName = :CourseName
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
