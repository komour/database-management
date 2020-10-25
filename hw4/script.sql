create table Student (
    Id int not null primary key,
    Name varchar(200) not null,
    GroupId int not null
);

create table Groups (
    Id int not null primary key,
    Name varchar(10) not null
);

create table Course (
    Id int not null primary key,
    Name varchar(200) not null
);

create table Mark (
    StudentId int not null,
    CourseId int not null,
    Mark int not null default 0,
    primary key (StudentId, CourseId)
);

create table Lecturer (
    Id int not null primary key,
    Name varchar(200) not null
);

create table Education (
    GroupId int not null,
    CourseId int not null,
    LecturerId int not null,
    primary key (GroupId, CourseId)
);

alter table Student
    add constraint studentGroupsFK foreign key (GroupId) references Groups (Id);

alter table Mark
    add constraint markStudentFK foreign key (StudentId) references Student (Id);

alter table Mark
    add constraint markCourseFK foreign key (CourseId) references Course (Id);

alter table Education
    add constraint educationGroupsFK foreign key (GroupId) references Groups (Id);

alter table Education
    add constraint educationCourseFK foreign key (CourseId) references Course (Id);

alter table Education
    add constraint educationLecturerFK foreign key (LecturerId) references Lecturer (Id);




insert into Groups
    (Id, Name) values
    (0, 'M3435');

insert into Groups
    (Id, Name) values
    (1, 'M3437');

insert into Groups
    (Id, Name) values
    (2, 'M3436');

insert into Groups
    (Id, Name) values
    (3, 'M3439');

insert into Student
    (Id, Name, GroupId) values
    (0, 'Постникова Анастасия Сергеевна', 0);

insert into Student
    (Id, Name, GroupId) values
    (1, 'Валеев Нурсан', 1);

insert into Student
    (Id, Name, GroupId) values
    (2, 'Ибрагимов Эмиль Халилович', 2);

insert into Student
    (Id, Name, GroupId) values
    (3, 'Тепляков Валерий Витальевич', 3);

insert into Course
    (Id, Name) values
    (0, 'Базы данных');

insert into Course
    (Id, Name) values
    (1, 'Парадигмы программирования');

insert into Course
    (Id, Name) values
    (2, 'Введение в программирование');

insert into Course
    (Id, Name) values
    (3, 'Технологии Java');

insert into Mark
    (StudentId, CourseId, Mark) values
    (0, 0, 5);

insert into Mark
    (StudentId, CourseId, Mark) values
    (1, 1, 5);

insert into Mark
    (StudentId, CourseId, Mark) values
    (2, 2, 5);

insert into Mark
    (StudentId, CourseId, Mark) values
    (3, 3, 5);

insert into Lecturer
    (Id, Name) values
    (0, 'Корнеев Георгий Александрович');

insert into Education
    (GroupId, CourseId, LecturerId) values
    (0, 0, 0);

insert into Education
    (GroupId, CourseId, LecturerId) values
    (3, 1, 0);