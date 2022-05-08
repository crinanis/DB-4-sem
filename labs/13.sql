USE UNIVER;


-- 1. Разработать скалярную функцию с именем COUNT_STUDENTS, которая вычисляет количество студентов на факультете, код которого задается параметром типа VARCHAR(20) с именем @faculty.
-- Использовать внутреннее соединение таблиц FACULTY, GROUPS, STUDENT. Опробовать работу функции.

ALTER FUNCTION COUNT_STUDENTS(@faculty varchar(20)) returns int
AS
BEGIN
	DECLARE @rc int = 0;
	SET @rc = (SELECT COUNT(*) from STUDENT s 
		join GROUPS g on s.IDGROUP = g.IDGROUP
			WHERE g.FACULTY  = @faculty);
return @rc;
end;

declare @f int = dbo.COUNT_STUDENTS('ХТиТ');
print 'Количество студентов на выбранном факультете: ' + convert(varchar(4), @f);

select FACULTY, dbo.COUNT_STUDENTS(FACULTY) from FACULTY;

-- Внести изменения в текст функции с помощью оператора ALTER с тем, чтобы функция принимала второй параметр @prof типа VARCHAR(20),
-- обозначающий специальность студентов. Для параметров определить значения по умолчанию NULL. Опробовать работу функции с помощью SELECT-запросов.

ALTER FUNCTION COUNT_STUDENTS(@faculty varchar(20) = NULL, @prof varchar(20) = NULL) returns int
AS
BEGIN
	DECLARE @rc int = 0;
	SET @rc = (SELECT COUNT(*) from STUDENT s 
		join GROUPS g on s.IDGROUP = g.IDGROUP
		join PULPIT p on g.FACULTY = p.FACULTY
			WHERE g.FACULTY  = @faculty and p.PULPIT = @prof);
return @rc;
end;

declare @f int = dbo.COUNT_STUDENTS('ТОВ','ОХ');
print 'Количество студентов на выбранном факультете: ' + convert(varchar(4), @f);

select FACULTY, dbo.COUNT_STUDENTS(FACULTY) from FACULTY;

-- 2. Разработать скалярную функцию с именем FSUBJECTS, принимающую параметр @p типа VARCHAR(20), значе-ние которого задает код кафедры (столбец SUB-JECT.PULPIT). 
-- Функция должна возвращать строку типа VARCHAR(300) с перечнем дисциплин в отчете. 
-- Создать и выполнить сценарий, который создает отчет, аналогичный представленному ниже. 
-- Примечание: использовать локальный статический кур-сор на основе SELECT-запроса к таблице SUBJECT.


CREATE FUNCTION FSUBJECTS(@p varchar(20)) returns varchar(300) 
AS
BEGIN
	DECLARE @ds varchar(20);
	DECLARE @d varchar(300) = 'Перечень дисциплин: ';
	DECLARE Disciplines CURSOR LOCAL STATIC
		FOR SELECT s.SUBJECT FROM SUBJECT s 
								WHERE s.PULPIT = @p;

	OPEN Disciplines;
	FETCH Disciplines into @ds;
	while @@FETCH_STATUS = 0
	BEGIN
		set @d = @d + ', ' + rtrim(@ds);
		FETCH Disciplines into @ds;
	END;
	return @d;
END;

select PULPIT,  dbo.FSUBJECTS(PULPIT) from PULPIT;


-- 3. Разработать табличную функцию FFACPUL, результаты работы которой продемонстрированы на рисунке ниже. 
-- Функция принимает два параметра, задающих код фа-культета (столбец FACULTY.FACULTY) и код кафедры (столбец PULPIT.PULPIT). Использует SELECT-запрос c левым внешним соединением между таблицами FACUL-TY и PULPIT. 
-- Если оба параметра функции равны NULL, то она воз-вращает список всех кафедр на всех факультетах. 
-- Если задан первый параметр (второй равен NULL), функция возвращает список всех кафедр заданного фа-культета. 
-- Если задан второй параметр (первый равен NULL), функция возвращает результирующий набор, содержащий строку, соответствующую заданной кафедре.


CREATE FUNCTION FFACPUL(@kf varchar(10), @kk varchar(10))returns table
AS RETURN
	SELECT f.FACULTY, p.PULPIT
		FROM FACULTY f join PULPIT p 
							ON f.FACULTY = p.FACULTY
						    WHERE f.FACULTY = ISNULL(@kf, f.FACULTY)
							AND p.PULPIT = isnull(@kk, p.PULPIT);

SELECT * FROM dbo.FFACPUL(NULL, NULL);
SELECT * FROM dbo.FFACPUL('ЛХФ', NULL);
SELECT * FROM dbo.FFACPUL(NULL, 'ЛВ');
SELECT * FROM dbo.FFACPUL('ИТ', 'ИСиТ');

-- 4. На рисунке ниже показан сценарий, демонстрирующий работу скалярной функции FCTEACHER. Функция при-нимает один параметр, задающий код кафедры. Функция возвращает количество преподавателей на заданной пара-метром кафедре. Если параметр равен NULL, то возвраща-ется общее количество преподавателей. 

CREATE FUNCTION FCTEACHER(@kk varchar(10)) returns int
AS
BEGIN
	DECLARE @rc int = (select count(*) from TEACHER
	WHERE PULPIT = ISNULL(@kk, PULPIT));
	return @rc;
END;

SELECT PULPIT, dbo.FCTEACHER(PULPIT) from PULPIT;