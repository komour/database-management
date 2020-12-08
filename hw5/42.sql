SELECT
  StudentId,
  StudentName,
  GroupId
FROM Students natural join Courses natural join Plan
WHERE CourseName = :CourseName
EXCEPT
SELECT
  StudentId,
  StudentName,
  GroupId
FROM Students natural join Courses natural join Marks natural join Plan
WHERE CourseName = :CourseName;