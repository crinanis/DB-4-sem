use UNIVER;

--1. Разработать представление с именем Преподаватель. Представление должно быть построено на основе SELECT-запроса к таблице TEACHER
--и содержать следующие столбцы: код (TEACHER), имя преподавателя (TEACHER_NAME), пол (GENDER), код кафедры (PULPIT). 

CREATE VIEW [Преподаватель] AS
	 SELECT	  TEACHER[Код],
			  TEACHER_NAME[Имя преподавателя],
			  GENDER[Пол],
			  PULPIT[Код кафедры]
	FROM TEACHER;

SELECT * FROM Преподаватель;	


--2. Разработать и создать представление с именем Количество кафедр. Представление должно быть построено на основе SELECT-запроса к таблицам FACULTY и PULPIT.
--Представление должно содержать следующие столбцы: факультет (FACULTY.FACULTY_NAME), количество кафедр (вычисляется на основе строк таблицы PULPIT). 

CREATE VIEW [Количество_кафедр] AS
	SELECT FACULTY.FACULTY_NAME[Факультет],
		   COUNT(*)[Количество кафедр]
	FROM PULPIT join FACULTY 
	on PULPIT.FACULTY=FACULTY.FACULTY
	group by FACULTY.FACULTY_NAME

SELECT * FROM Количество_кафедр


--3. Разработать и создать представление с именем Аудитории. Представление должно быть построено на основе таблицы AUDITORIUM и содержать столбцы: код (AUDITORIUM), наименование аудитории (AUDITORIUM_NAME). 
--Представление должно отображать только лекционные аудитории (в столбце AUDITORIUM_TYPE строка, начинающаяся с символа ЛК) и допускать выполнение оператора INSERT, UPDATE и DELETE.

CREATE VIEW [Аудитории] AS
	SELECT AUDITORIUM[Код], AUDITORIUM_NAME[Наименование аудитории], AUDITORIUM_TYPE[Тип аудитории]  
	FROM AUDITORIUM WHERE AUDITORIUM_TYPE like 'ЛК%'

SELECT * FROM Аудитории

INSERT Аудитории values ('601-4', '601-4', 'ЛК');
UPDATE Аудитории SET [Тип аудитории] = 'ПП';
DELETE FROM Аудитории WHERE [Наименование аудитории] = '597'


--4. Разработать и создать представление с именем Лекционные_аудитории. 
--Представление должно быть построено на основе SELECT-запроса к таблице AUDITORIUM и содержать следующие столбцы: код (AUDITORIUM), наименование аудитории (AUDITORIUM_NAME). 
--Представление должно отображать только лекционные аудитории (в столбце AUDITORIUM_TYPE строка, начинающаяся с символов ЛК). 
--Выполнение INSERT и UPDATE допускает-ся, но с учетом ограничения, задаваемого опцией WITH CHECK OPTION. 

ALTER VIEW [Аудитории] AS
	SELECT AUDITORIUM[Код], AUDITORIUM_NAME[Наименование аудитории], AUDITORIUM_TYPE[Тип аудитории]  
	FROM AUDITORIUM WHERE AUDITORIUM_TYPE like 'ЛК%' WITH CHECK OPTION;

SELECT * FROM Аудитории

INSERT Аудитории values ('601-4', '601-4', 'ЛК');
INSERT Аудитории values ('603-4', '603-4', 'ЛК');
INSERT Аудитории values ('605-4', '605-4', 'ЛР');


--5. Разработать представление с именем Дисциплины. Представление должно быть построено на основе SELECT-запроса к таблице SUBJECT, отображать все дисциплины в алфавитном порядке и содержать следующие столбцы:
--код (SUBJECT), наименование дисциплины (SUBJECT_NAME) и код кафедры (PULPIT). Использовать TOP и ORDER BY.

CREATE VIEW Дисциплины(Код, Наименование_дисциплины, Код_кафедры) AS
	SELECT TOP 10 SUBJECT, SUBJECT_NAME, PULPIT.PULPIT
	FROM SUBJECT join PULPIT on SUBJECT.PULPIT=PULPIT.PULPIT
	ORDER BY SUBJECT_NAME asc;

SELECT * from Дисциплины;


--6. Изменить представление Количество_кафедр, созданное в задании 2 так, чтобы оно было привязано к базовым таблицам. 
--Продемонстрировать свойство привязанности представления к базовым таблицам. Примечание: использовать опцию SCHEMABINDING. 

ALTER VIEW [Количество_кафедр] WITH SCHEMABINDING AS
	SELECT f.FACULTY_NAME[Факультет],
	count(*)[Количество кафедр]
	FROM dbo.PULPIT p join dbo.FACULTY f
	on p.FACULTY=f.FACULTY
	group by f.FACULTY_NAME 

INSERT INTO [Количество_кафедр] values ('RRRR', 10);