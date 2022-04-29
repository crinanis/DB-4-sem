-- 1. ����������� T-SQL-������, � ��-�����: 
-- �������� ���������� ���� char, varchar, datetime, time, int, smallint, tinyint, numeric(12, 5); 
-- ������ ��� ���������� ��������-����������� � ��������� ����������;
-- ��������� ������������ �������� ��������� ���� ���������� � ��-����� ��������� SET, ����� �� ���� ���������� ��������� ��������, 
-- ���������� � ���������� ������� SELECT; 
-- ���� �� ���������� �������� ��� ������������� � �� ����������� �� ��������, ���������� ���������� ��������� ��������� ��������
--� ������� ��������� SELECT; 
-- �������� ����� �������� ���������� ������� � ������� ��������� SELECT, �������� ������ �������� ���������� ����������� � ������� ��������� PRINT. 
--���������������� ����������.

USE UNIVER;

CREATE TABLE LAB8(
	currentTime time,
	anynum smallint,        --  -2^15 (-32,768) to 2^15-1 (32,767)
	anothernum tinyint,		--	0 to 255
	number numeric(12,5)
)

INSERT INTO LAB8 (currentTime, anynum, anothernum, number) 
	VALUES ('10:40:35', -32000, 12,  1234567.12345),
		   ('12:00:00', -15876, 99,  12343.12345),
		   ('18:55:55', 2756,   32,  123456.1),
		   ('21:05:00', 32555,  255, 12.1234);


DECLARE @ch char(4) = 'char',
		@vch varchar(50) = 'this is _varchar',
		@dtm datetime,
		@tm time,
		@i int,
		@smi smallint,
		@tni tinyint,
		@num numeric(12,5);
SET @dtm = getdate();
SELECT @tm = max(currentTime), @smi = avg(anynum), @tni = min(anothernum), @num = sum(number) FROM LAB8;
SELECT @ch 'char', @vch 'varchar', @dtm 'datetime', @tm 'time';
PRINT '������� �������� � ������� print: smallint ' + convert(char, @smi) + 'tinyint ' + convert(char,@tni) + 'numeric ' + convert(char, @num);
PRINT 'Uninitialised ' + cast(@i as char);

-- 2. ����������� ������, � ������� ������������ ����� ����������� ���������. ����� ����� ����������� ��������� 200, 
-- �� ������� ���������� ���������, ������� ����������� ���������, ���������� ���������, ����������� ������� ������ �������, � ������� ����� ���������. 
-- ����� ����� ����������� ��������� ������ 200, �� ������� ��������� � ������� ����� �����������.


DECLARE @capacity int = (SELECT sum(AUDITORIUM_CAPACITY) FROM AUDITORIUM),
		@amount real,
		@avr_capacity real,
		@amount_lower real,
		@percent real;
IF @capacity > 200
BEGIN
SET    @avr_capacity = (SELECT avg(AUDITORIUM_CAPACITY) from AUDITORIUM);
SET	   @amount = (SELECT count(AUDITORIUM) FROM AUDITORIUM);
SET	   @amount_lower = (SELECT count(*) FROM AUDITORIUM WHERE AUDITORIUM_CAPACITY < @avr_capacity);
SET    @percent = (@amount_lower/@amount)*100;
SELECT @capacity 'Capacity', @avr_capacity  'Average capacity', @amount_lower 'Amount lower', @percent 'Percent'
end
ELSE IF @capacity < 200 print @capacity;


-- 3.	����������� T-SQL-������, ��-����� ������� �� ������ ���������� ����������: 
--@@ROWCOUNT (����� ������-������ �����); 
-- @@VERSION (������ SQL Server);
-- @@SPID (���������� ��������� ������������� ��������, ��������-��� �������� �������� ��������-���); 
-- @@ERROR (��� ��������� ����-��); 
-- @@SERVERNAME (��� �������); 
-- @@TRANCOUNT (���������� ������� ����������� ����������); 
-- @@FETCH_STATUS (�������� ��-�������� ���������� ����� ������-��������� ������); 
-- @@NESTLEVEL (������� ���-�������� ������� ���������).
--���������������� ���������.

SELECT @@ROWCOUNT '����� ������������ �����', @@VERSION '������ SQL Server', @@SPID '��������� ������������� ��������', 
	   @@ERROR '��� ��������� ������', @@SERVERNAME '��� �������', @@TRANCOUNT '������� ����������� ����������',
	   @@FETCH_STATUS '�������� ���������� ���������� �����', @@NESTLEVEL '������� ����������� ���������';


-- 4. ����������� T-SQL-�������, �����������: 


-- ���������� �������� ���������� z ��� ��������� �������� �������� ������;

DECLARE @t float = 1.5,
		@x float = 2.78,
		@z float;
	IF (@t>@x) SET @z=POWER(SIN(@t),2)
	ELSE IF (@t<@x) SET @z=4*(@t+@x)
	ELSE SET @z=1-EXP(@x-2);
PRINT 'z= ' + convert(varchar, @z);


-- �������������� ������� ��� �������� � ����������� (��������, �������� ������� ���������� � �������� �. �.);

--DECLARE @str varchar(100) = (SELECT TOP 1 NAME FROM STUDENT);
DECLARE @str varchar(100) = '    Budanowa    Ksenya  Andreevna    ';
SET @str = rtrim(ltrim(@str));
DECLARE @counter int = 0;
WHILE(@counter < LEN(@str))
	BEGIN
	if(SUBSTRING(@str, @counter, 1) = ' ')
		begin
		if(SUBSTRING(@str, @counter + 1, 1) = ' ')
			begin
			set @str = substring(@str, 1, @counter) + substring(@str, @counter + 2, len(@str));
			set @counter = @counter - 1;
			end
		end
	set @counter = @counter+1;
	END

SELECT substring(@str, 1, charindex(' ', @str)) + substring(@str, charindex(' ', @str) + 1, 1) + '. ' + 
		substring(@str, charindex(' ', @str, charindex(' ', @str) + 1) + 1, 1)+'.'


-- ����� ���������, � ������� ���� �������� � ��������� ������, � ����������� �� ��������;

DECLARE @mon int = month(getdate());
if @mon = 12 set @mon = 0;
SELECT NAME[��� ��������], 2022-YEAR(BDAY)[�������], MONTH(BDAY)[����� ��������]
FROM STUDENT WHERE MONTH(BDAY) = @mon + 1


-- ����� ��� ������, � ������� �������� ��������� ������ ������� ������� �� ����.

DECLARE @group int = 5;
SELECT TOP(1) DATENAME(weekday, PDATE) AS "���� ������"
FROM PROGRESS p
	JOIN STUDENT s ON p.IDSTUDENT = s.IDSTUDENT
	JOIN GROUPS g ON s.IDGROUP = g.IDGROUP
WHERE g.IDGROUP = @group;


-- ������������������ ����������� IF� ELSE �� ������� ������� ������ ������ ���� ������ �_UNIVER.

DECLARE @tech tinyint;
	SET @tech = (SELECT COUNT(*) FROM TEACHER);
IF @tech > 20
	BEGIN
		PRINT 'Amount of teachers > 20:  ' + cast(@tech as varchar(5));
	END;
ELSE
	BEGIN
		PRINT 'Amount of teachers < 20: ' + cast(@tech as varchar(5));
	END;


-- ����������� ��������, � ������� � ������� CASE ������������� ������, ���������� ���������� ���������� ���������� ��� ����� ���������.

SELECT CASE
	WHEN NOTE between 9 and 10 then 'Good'
	WHEN NOTE between 8 and 9 then 'Passable'
	WHEN NOTE between 7 and 8 then 'Okay'
	ELSE 'Not okay'
END NOTE, count(*) [����������]
	FROM PROGRESS p
		JOIN STUDENT s on p.IDSTUDENT = s.IDSTUDENT
		JOIN GROUPS g on s.IDGROUP = g.IDGROUP
			WHERE FACULTY = '����'
GROUP BY case
	WHEN NOTE between 9 and 10 then 'Good'
	WHEN NOTE between 8 and 9 then 'Passable'
	WHEN NOTE between 7 and 8 then 'Okay'
	ELSE 'Not okay'
end;

-- 7. ������� ��������� ��������� ������� �� ���� �������� � 10 �����, ��������� �� � ������� ����������. ������������ �������� WHILE.

CREATE TABLE #example
(	tibd int,
	tfield varchar(100),
	tfield1 datetime
)

SET nocount on; --�� �������� ��������� � ����� �����
DECLARE @ii int = 0;
WHILE @ii < 10
	BEGIN
INSERT #example(tibd,tfield, tfield1)
	values(floor(300*rand()), replicate('strings',5), GETDATE());
IF(@ii % 100 = 0)
	print @ii;
SET @ii = @ii + 1;
	END;
SELECT * FROM #example


-- 8. ����������� ������, ��������������� ������������� ��������� RETURN.

DECLARE @xx int = 1
print @xx + 1
print @xx + 2
Return
print @xx + 3


-- 9. ����������� �������� � ��������, � ������� ������������ ��� ��������� ������ ����� TRY � CATCH. 
--��������� ������� ERROR_NUMBER (��� ��������� ������), 
--ERROR_MESSAGE (��������� �� ������), ERROR_LINE (��� ��������� ������), 
--ERROR_PROCEDURE (��� ��������� ��� NULL), ERROR_SEVERITY (������� ����������� ������), ERROR_STATE (����� ������). ���������������� ���������.

BEGIN TRY
update dbo.GROUPS set YEAR_FIRST = 'year'
WHERE YEAR_FIRST = 2013
END TRY
BEGIN CATCH
print ERROR_NUMBER() -- ��� ��������� ������
print ERROR_MESSAGE() -- ��������� �� ������
print ERROR_LINE() -- ��� ��������� ������
print ERROR_PROCEDURE() -- ��� ��������� ��� NULL
print ERROR_SEVERITY() -- ������� ����������� ������
print ERROR_STATE() -- ����� ������
END CATCH
