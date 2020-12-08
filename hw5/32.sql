SELECT
  StudentId,
  StudentName,
  GroupId
FROM Students natural join Courses natural join Marks
WHERE CourseName = :CourseName and Mark = :Mark;