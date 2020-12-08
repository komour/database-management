SELECT
  StudentName,
  CourseName
FROM 
(SELECT
  StudentId,
  StudentName,
  CourseName
FROM
Students natural join Courses natural join Plan
EXCEPT
SELECT
  StudentId,
  StudentName,
  CourseName
FROM
Students natural join Courses natural join Marks
WHERE Mark = '4' or Mark = '5') SubQuery