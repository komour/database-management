\1. **Первая нормальная форма**

1.1. **Описание** *

Изначальное отношение уже находится в 1НФ, т.к. :
1) В отношении нет повторяющихся групп
2) Все атрибуты атомарны
3) У отношения есть ключ - {StudentId, CourseId}

1.2. **Результат** *

*Для исходного отношения укажите на какие отношения вы его разбили в формате «Исходное отношение => полученное отношение ; полученное отношение ; ...». Где все отношения заданы в формате «(атрибут1, атрибут2, ...)»*

(StudentId, StudentName, GroupId, GroupName, CourseId, CourseName, LecturerId, LecturerName, Mark) => (StudentId, StudentName, GroupId, GroupName, CourseId, CourseName, LecturerId, LecturerName, Mark)

\2. Вторая нормальная форма

2.1. **Описание** *

Начальное множество ФЗ:
1. StudentId -> StudentName, GroupId, GroupName
2. GroupId -> GroupName
3. CourseId -> CourseName
4. LecturerId -> LecturerName
5. StudentId, CourseId -> Mark
6. GroupId, CourseId -> LecturerId, LecturerName
7. GroupName -> GroupId

Отношение находится во 2НФ, если неключевые атрибуты функционально зависят от ключа в целом (не от части ключа), поэтому декомпозируем отношение по мешающим ФЗ.

2.2. **Результат** *

(StudentId, StudentName, GroupId, GroupName, CourseId, CourseName, LecturerId, LecturerName, Mark) => (StudentId, StudentName, GroupId, GroupName) ; (GroupId, GroupName) ; (CourseId, CourseName) ; (LecturerId, LecturerName) ; (StudentId, CourseId, Mark) ; (GroupId, CourseId, LecturerId, LecturerName)

\3. **Третья нормальная форма**

3.1. **Описание **

Избавимся от транзитивных зависимостей в 2.2 . Разобьем отношения  (StudentId, StudentName, GroupId, GroupName) и (GroupId, CourseId, LecturerId, LecturerName).

3.2. **Результат** 

(StudentId, StudentName, GroupId, GroupName) => (StudentId, StudentName, GroupId) ; (GroupId, GroupName)
(GroupId, GroupName) => (GroupId, GroupName)
(CourseId, CourseName) => (CourseId, CourseName)
(LecturerId, LecturerName) => (LecturerId, LecturerName)
(GroupId, CourseId, LecturerId, LecturerName) => (GroupId, CourseId, LecturerId) ; (LecturerId, LecturerName)
(StudentId, CourseId, Mark) => (StudentId, CourseId, Mark)

Б. **Нормальная форма Бойса-Кодта**

Б.1. **Описание**

Все отношения из 3.2 уже находятся в НФБК по определению - в каждой нетривиальной функциональной зависимости X→Y, X является надключом.

Б.2. **Результат**

(StudentId, StudentName, GroupId, GroupName) => (StudentId, StudentName, GroupId)
(GroupId, GroupName) => (GroupId, GroupName)
(CourseId, CourseName) => (CourseId, CourseName)
(LecturerId, LecturerName) => (LecturerId, LecturerName)
(GroupId, CourseId, LecturerId, LecturerName) => (GroupId, CourseId, LecturerId)
(StudentId, CourseId, Mark) => (StudentId, CourseId, Mark)

\4. **Четвёртая нормальная форма**

4.1. **Описание** 

Декомпозируем первое отношение, содержащие МЗ.

4.2. **Результат** 

(StudentId, StudentName, GroupId) => (StudentId, StudentName) ; (StudentId, GroupId)
(GroupId, GroupName) => (GroupId, GroupName)
(CourseId, CourseName) => (CourseId, CourseName)
(LecturerId, LecturerName) => (LecturerId, LecturerName)
(GroupId, CourseId, LecturerId) => (GroupId, CourseId, LecturerId)
(StudentId, CourseId, Mark) => (StudentId, CourseId, Mark)

\5. **Пятая нормальная форма**

5.1. **Описание** 

5.2. **Результат** 

Для каждого отношения из предыдущей нормальной формы укажите на какие отношения вы его разбили в формате «Исходное отношение => полученное отношение ; полученное отношение ; ...». Где все отношения заданы в формате «(атрибут1, атрибут2, ...)»