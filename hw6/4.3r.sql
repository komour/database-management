SELECT
  s.StudentId
FROM Students s
WHERE NOT EXISTS (SELECT
  s.StudentId
FROM Lecturers l,
     Plan p
WHERE NOT EXISTS (SELECT
  m.StudentId,
  m.CourseId
FROM Marks m
WHERE m.StudentId = s.StudentId
AND m.CourseId = p.CourseId)
AND l.LecturerId = p.LecturerId
AND l.LecturerName = :LecturerName);