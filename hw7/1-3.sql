DELETE FROM Groups
WHERE GroupId NOT IN (SELECT
    GroupId
  FROM Students)