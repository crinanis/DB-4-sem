-- 1. Разработать T-SQL-скрипт, в ко-тором: 
-- объявить переменные типа char, varchar, datetime, time, int, smallint, tinyint, numeric(12, 5); 
-- первые две переменные проиници-ализировать в операторе объявления;
-- присвоить произвольные значения следующим двум переменным с по-мощью оператора SET, одной из этих переменных присвоить значение, 
-- полученное в результате запроса SELECT; 
-- одну из переменных оставить без инициализации и не присваивать ей значения, оставшимся переменным присвоить некоторые значения
--с помощью оператора SELECT; 
-- значения одной половины переменных вывести с помощью оператора SELECT, значения другой половины переменных распечатать с помощью оператора PRINT. 
--Проанализировать результаты.

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
PRINT 'Выводим элементы с помощью print: smallint ' + convert(char, @smi) + 'tinyint ' + convert(char,@tni) + 'numeric ' + convert(char, @num);
PRINT 'Uninitialised ' + cast(@i as char);

-- 2. Разработать скрипт, в котором определяется общая вместимость аудиторий. Когда общая вместимость превышает 200, 
-- то вывести количество аудиторий, среднюю вместимость аудиторий, количество аудиторий, вместимость которых меньше средней, и процент таких аудиторий. 
-- Когда общая вместимость аудиторий меньше 200, то вывести сообщение о размере общей вместимости.


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


-- 3.	Разработать T-SQL-скрипт, ко-торый выводит на печать глобальные переменные: 
--@@ROWCOUNT (число обрабо-танных строк); 
-- @@VERSION (версия SQL Server);
-- @@SPID (возвращает системный идентификатор процесса, назначен-ный сервером текущему подключе-нию); 
-- @@ERROR (код последней ошиб-ки); 
-- @@SERVERNAME (имя сервера); 
-- @@TRANCOUNT (возвращает уровень вложенности транзакции); 
-- @@FETCH_STATUS (проверка ре-зультата считывания строк резуль-тирующего набора); 
-- @@NESTLEVEL (уровень вло-женности текущей процедуры).
--Проанализировать результат.

SELECT @@ROWCOUNT 'Число обработанных строк', @@VERSION 'Версия SQL Server', @@SPID 'Системный идентификатор процесса', 
	   @@ERROR 'Код последней ошибки', @@SERVERNAME 'Имя сервера', @@TRANCOUNT 'Уровень вложенности транзакции',
	   @@FETCH_STATUS 'Проверка результата считывания строк', @@NESTLEVEL 'Уровень вложенности процедуры';


-- 4. Разработать T-SQL-скрипты, выполняющие: 


-- вычисление значений переменной z для различных значений исходных данных;

DECLARE @t float = 1.5,
		@x float = 2.78,
		@z float;
	IF (@t>@x) SET @z=POWER(SIN(@t),2)
	ELSE IF (@t<@x) SET @z=4*(@t+@x)
	ELSE SET @z=1-EXP(@x-2);
PRINT 'z= ' + convert(varchar, @z);


-- преобразование полного ФИО студента в сокращенное (например, Макейчик Татьяна Леонидовна в Макейчик Т. Л.);

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


-- поиск студентов, у которых день рождения в следующем месяце, и определение их возраста;

DECLARE @mon int = month(getdate());
if @mon = 12 set @mon = 0;
SELECT NAME[Имя студента], 2022-YEAR(BDAY)[Возраст], MONTH(BDAY)[Месяц рождения]
FROM STUDENT WHERE MONTH(BDAY) = @mon + 1


-- поиск дня недели, в который студенты некоторой группы сдавали экзамен по СУБД.

DECLARE @group int = 5;
SELECT TOP(1) DATENAME(weekday, PDATE) AS "День недели"
FROM PROGRESS p
	JOIN STUDENT s ON p.IDSTUDENT = s.IDSTUDENT
	JOIN GROUPS g ON s.IDGROUP = g.IDGROUP
WHERE g.IDGROUP = @group;


-- Продемонстрировать конструкцию IF… ELSE на примере анализа данных таблиц базы данных Х_UNIVER.

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


-- Разработать сценарий, в котором с помощью CASE анализируются оценки, полученные студентами некоторого факультета при сдаче экзаменов.

SELECT CASE
	WHEN NOTE between 9 and 10 then 'Good'
	WHEN NOTE between 8 and 9 then 'Passable'
	WHEN NOTE between 7 and 8 then 'Okay'
	ELSE 'Not okay'
END NOTE, count(*) [Количество]
	FROM PROGRESS p
		JOIN STUDENT s on p.IDSTUDENT = s.IDSTUDENT
		JOIN GROUPS g on s.IDGROUP = g.IDGROUP
			WHERE FACULTY = 'ХТиТ'
GROUP BY case
	WHEN NOTE between 9 and 10 then 'Good'
	WHEN NOTE between 8 and 9 then 'Passable'
	WHEN NOTE between 7 and 8 then 'Okay'
	ELSE 'Not okay'
end;

-- 7. Создать временную локальную таблицу из трех столбцов и 10 строк, заполнить ее и вывести содержимое. Использовать оператор WHILE.

CREATE TABLE #example
(	tibd int,
	tfield varchar(100),
	tfield1 datetime
)

SET nocount on; --не выводить сообщения о вводе строк
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


-- 8. Разработать скрипт, демонстрирующий использование оператора RETURN.

DECLARE @xx int = 1
print @xx + 1
print @xx + 2
Return
print @xx + 3


-- 9. Разработать сценарий с ошибками, в котором используются для обработки ошибок блоки TRY и CATCH. 
--Применить функции ERROR_NUMBER (код последней ошибки), 
--ERROR_MESSAGE (сообщение об ошибке), ERROR_LINE (код последней ошибки), 
--ERROR_PROCEDURE (имя процедуры или NULL), ERROR_SEVERITY (уровень серьезности ошибки), ERROR_STATE (метка ошибки). Проанализировать результат.

BEGIN TRY
update dbo.GROUPS set YEAR_FIRST = 'year'
WHERE YEAR_FIRST = 2013
END TRY
BEGIN CATCH
print ERROR_NUMBER() -- код последней ошибки
print ERROR_MESSAGE() -- сообщение об ошибке
print ERROR_LINE() -- код последней ошибки
print ERROR_PROCEDURE() -- имя процедуры или NULL
print ERROR_SEVERITY() -- уровень серьезности ошибки
print ERROR_STATE() -- метка ошибки
END CATCH
