В нашей схеме информация о курсах, которые изучает студент, находится в табличке Plan, которая имеет колонки GroupId, CourseId, LecturerId. Таким образом все студенты группы в любом случае изучают одни и те же курсы, поэтому данная проверка не нужна. Можно было бы добавить такую проверку, если бы, например, в табличке Plan хранился StudentId вместо GroupId.