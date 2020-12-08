SELECT DISTINCT
  StudentId,
  StudentName,
  GroupId
FROM Students natural join Marks
WHERE CourseId = :CourseId and Mark = :Mark;