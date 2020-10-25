SELECT DISTINCT
  s.StudentId
FROM Students s
EXCEPT
SELECT DISTINCT
  s.StudentId
FROM Students s,
     Plan p,
     Lecturers l,
     Marks m
WHERE s.StudentId = m.StudentId
AND s.GroupId = p.GroupId
AND p.CourseId = m.CourseId
AND p.LecturerId = l.LecturerId
AND l.LecturerName = :LecturerName;