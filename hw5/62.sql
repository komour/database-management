SELECT DISTINCT
  StudentId
FROM Students
EXCEPT
SELECT DISTINCT
  StudentId 
FROM Students natural join Marks natural join Plan natural join Lecturers
WHERE LecturerName = :LecturerName