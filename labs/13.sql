USE UNIVER;


-- 1. ����������� ��������� ������� � ������ COUNT_STUDENTS, ������� ��������� ���������� ��������� �� ����������, ��� �������� �������� ���������� ���� VARCHAR(20) � ������ @faculty.
-- ������������ ���������� ���������� ������ FACULTY, GROUPS, STUDENT. ���������� ������ �������.

ALTER FUNCTION COUNT_STUDENTS(@faculty varchar(20)) returns int
AS
BEGIN
	DECLARE @rc int = 0;
	SET @rc = (SELECT COUNT(*) from STUDENT s 
		join GROUPS g on s.IDGROUP = g.IDGROUP
			WHERE g.FACULTY  = @faculty);
return @rc;
end;

declare @f int = dbo.COUNT_STUDENTS('����');
print '���������� ��������� �� ��������� ����������: ' + convert(varchar(4), @f);

select FACULTY, dbo.COUNT_STUDENTS(FACULTY) from FACULTY;

-- ������ ��������� � ����� ������� � ������� ��������� ALTER � ���, ����� ������� ��������� ������ �������� @prof ���� VARCHAR(20),
-- ������������ ������������� ���������. ��� ���������� ���������� �������� �� ��������� NULL. ���������� ������ ������� � ������� SELECT-��������.

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

declare @f int = dbo.COUNT_STUDENTS('���','��');
print '���������� ��������� �� ��������� ����������: ' + convert(varchar(4), @f);

select FACULTY, dbo.COUNT_STUDENTS(FACULTY) from FACULTY;

-- 2. ����������� ��������� ������� � ������ FSUBJECTS, ����������� �������� @p ���� VARCHAR(20), �����-��� �������� ������ ��� ������� (������� SUB-JECT.PULPIT). 
-- ������� ������ ���������� ������ ���� VARCHAR(300) � �������� ��������� � ������. 
-- ������� � ��������� ��������, ������� ������� �����, ����������� ��������������� ����. 
-- ����������: ������������ ��������� ����������� ���-��� �� ������ SELECT-������� � ������� SUBJECT.


CREATE FUNCTION FSUBJECTS(@p varchar(20)) returns varchar(300) 
AS
BEGIN
	DECLARE @ds varchar(20);
	DECLARE @d varchar(300) = '�������� ���������: ';
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


-- 3. ����������� ��������� ������� FFACPUL, ���������� ������ ������� ������������������ �� ������� ����. 
-- ������� ��������� ��� ���������, �������� ��� ��-�������� (������� FACULTY.FACULTY) � ��� ������� (������� PULPIT.PULPIT). ���������� SELECT-������ c ����� ������� ����������� ����� ��������� FACUL-TY � PULPIT. 
-- ���� ��� ��������� ������� ����� NULL, �� ��� ���-������� ������ ���� ������ �� ���� �����������. 
-- ���� ����� ������ �������� (������ ����� NULL), ������� ���������� ������ ���� ������ ��������� ��-��������. 
-- ���� ����� ������ �������� (������ ����� NULL), ������� ���������� �������������� �����, ���������� ������, ��������������� �������� �������.


CREATE FUNCTION FFACPUL(@kf varchar(10), @kk varchar(10))returns table
AS RETURN
	SELECT f.FACULTY, p.PULPIT
		FROM FACULTY f join PULPIT p 
							ON f.FACULTY = p.FACULTY
						    WHERE f.FACULTY = ISNULL(@kf, f.FACULTY)
							AND p.PULPIT = isnull(@kk, p.PULPIT);

SELECT * FROM dbo.FFACPUL(NULL, NULL);
SELECT * FROM dbo.FFACPUL('���', NULL);
SELECT * FROM dbo.FFACPUL(NULL, '��');
SELECT * FROM dbo.FFACPUL('��', '����');

-- 4. �� ������� ���� ������� ��������, ��������������� ������ ��������� ������� FCTEACHER. ������� ���-������ ���� ��������, �������� ��� �������. ������� ���������� ���������� �������������� �� �������� ����-������ �������. ���� �������� ����� NULL, �� ��������-���� ����� ���������� ��������������. 

CREATE FUNCTION FCTEACHER(@kk varchar(10)) returns int
AS
BEGIN
	DECLARE @rc int = (select count(*) from TEACHER
	WHERE PULPIT = ISNULL(@kk, PULPIT));
	return @rc;
END;

SELECT PULPIT, dbo.FCTEACHER(PULPIT) from PULPIT;