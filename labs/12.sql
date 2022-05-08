use univer;

-- 1. Разработать хранимую процедуру без параметров с именем PSUBJECT. Процедура формирует результирующий набор на основе таблицы SUBJECT, аналогичный набору, представленному на рисункe.
-- К точке вызова процедура должна возвращать количество строк, выведенных в результирующий набор.


ALTER PROCEDURE PSUBJECT AS
begin
	declare @k int = (select count(*) from SUBJECT);
	select SUBJECT[Код], SUBJECT_NAME[Дисциплина], PULPIT[Кафедра] from SUBJECT;
	return @k;
end;

declare @res int = 0;
EXEC @res = PSUBJECT;
print 'количество строк= ' + convert(varchar(5), @res);


-- 2. Найти процедуру PSUBJECT с помощью обозрева-теля объектов (Object Explorer) SSMS и через кон-текстное меню создать сценарий на изменение про-цедуры оператором ALTER.
-- Изменить процедуру PSUBJECT, созданную в задании 1, таким образом, чтобы она принимала два параметра с именами @p и @c. Параметр @p является входным, 
-- имеет тип VARCHAR(20) и значение по умолчанию NULL. Параметр @с является выход-ным, имеет тип INT.
-- Процедура PSUBJECT должна формировать результирующий набор, аналогичный набору, представленному на рисунке выше, но при этом содержать строки, соответствующие коду кафедры,
-- заданному параметром @p. Кроме того, процедура долж-на формировать значение выходного параметра @с, равное количеству строк в результирующем наборе, а также возвращать значение к точке вызова,
-- равное общему количеству дисциплин (количеству строк в таблице SUBJECT). 


ALTER PROCEDURE PSUBJECT @p varchar(20), @c int output AS
BEGIN
	DECLARE @k int = (select count(*) FROM SUBJECT);
	PRINT 'parameters @p = ' + @p + ', @c = ' + convert(varchar(3), @c);
	SELECT * FROM SUBJECT WHERE SUBJECT = @p;
	SET @c = @@ROWCOUNT;
	RETURN @k;
END;

DECLARE @k int = 0, @p varchar(30), @r int = 0; 

EXEC @k = PSUBJECT   @p = 'БД', @c = @r output;
print 'Общее количество дисциплин = ' + convert(varchar(3),@k);
print 'Количество дисциплин определённой кафедры = ' + convert(varchar(3),@r);


-- 3. Создать временную локальную таблицу с именем #SUBJECT. Наименование и тип столбцов таблицы должны соответствовать столбцам результирующего набора процедуры PSUBJECT, разработанной в задании 2. 
-- Изменить процедуру PSUBJECT таким образом, чтобы она не содержала выходного параметра.
-- Применив конструкцию INSERT… EXECUTE с модифицированной процедурой PSUBJECT, добавить строки в таблицу #SUBJECT. 

ALTER PROCEDURE PSUBJECT @p varchar(20) AS
BEGIN
	DECLARE @k int = (select count(*) FROM SUBJECT);
	SELECT * FROM SUBJECT WHERE SUBJECT = @p;
END;

CREATE TABLE #SUBJECT
(	Код_кафедры varchar(20) primary key,
	Дисциплина nvarchar(20),
	Кафедра nvarchar(20)
)

INSERT #SUBJECT exec PSUBJECT @p = 'БД';
INSERT #SUBJECT exec PSUBJECT @p = 'ЛВ';

SELECT * FROM #SUBJECT;

-- 4. Разработать процедуру с именем PAUDITORIUM_INSERT. Процедура принимает четыре вход-ных параметра: @a, @n, @c и @t. Параметр @a имеет тип CHAR(20), параметр @n имеет тип VAR-CHAR(50), параметр @c имеет тип INT и значение по умолчанию 0, параметр @t имеет тип CHAR(10).
-- Процедура добавляет строку в таблицу AUDITORIUM. Значения столбцов AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_CAPACITY и AUDITORIUM_TYPE добавляемой строки задаются соответственно параметрами @a, @n, @c и @t.
-- Процедура PAUDITORIUM_INSERT должна применять механизм TRY/CATCH для обработки ошибок. В случае возникновения ошибки, процедура должна формировать сообщение, содержащее код ошибки, уровень серьезности и текст сообщения в стандартный выходной поток. 
-- Процедура должна возвращать к точке вызова зна-чение -1 в том случае, если произошла ошибка и 1, если выполнение успешно. 
-- Опробовать работу процедуры с различными зна-чениями исходных данных, которые вставляются в таблицу.


CREATE PROCEDURE PAUDITORIUM_INSERT @a char(20), @n varchar(50), @c int = 0, @t char(10)  AS
DECLARE @rc int = 1;
BEGIN TRY
	INSERT INTO AUDITORIUM(AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_CAPACITY, AUDITORIUM_TYPE)
			VALUES (@a, @n, @c, @t)
	return @rc;
END TRY
BEGIN CATCH
	print 'Номер ошибки: ' + convert(varchar(6), error_number());
	print 'Сообщение: ' + error_message();
	print 'Уровень: ' + convert(varchar(6), error_severity());
	print 'Метка: ' + convert(varchar(8), error_state());
	print 'Номер строки: ' + convert(varchar(8), error_line());
	if error_procedure() is not null
		print 'Имя процедуры: ' + error_procedure();
	return -1;
END CATCH;

declare @rc int;
exec @rc = PAUDITORIUM_INSERT @a = '2555', @n = '2555', @c = 50, @t = 'ЛК';
print 'Код ошибки: ' + convert(varchar(3), @rc);


-- 5. Разработать процедуру с именем SUBJECT_REPORT, формирующую в стандартный вы-ходной поток отчет со списком дисциплин на конкретной кафедре. В отчет должны быть выведены краткие названия (поле SUBJECT) из таблицы SUBJECT в одну строку через запятую (использовать встроенную функцию RTRIM). Процедура имеет входной параметр с именем @p типа CHAR(10), ко-торый предназначен для указания кода кафедры.
-- В том случае, если по заданному значению @p невозможно определить код кафедры, процедура должна генерировать ошибку с сообщением ошибка в параметрах. 
-- Процедура SUBJECT_REPORT должна возвра-щать к точке вызова количество дисциплин, отображенных в отчете. 


CREATE PROCEDURE SUBJECT_REPORT  @p char(10) AS
DECLARE @rc int = 0;
BEGIN TRY   
      DECLARE @tv char(20), @t char(300) = ' ';  
      DECLARE Spisok CURSOR for 
		 SELECT s.SUBJECT FROM SUBJECT s WHERE s.PULPIT = @p;
			if not exists (SELECT s.SUBJECT FROM SUBJECT s WHERE s.PULPIT = @p)
          raiserror('ошибка', 11, 1);
      else 
      OPEN Spisok;	  
		FETCH Spisok INTO @tv;   
		print 'Список дисциплин на кафедре: ';   
		while @@fetch_status = 0                                     
		BEGIN 
			SET @t = rtrim(@tv) + ', ' + @t;  
			SET @rc = @rc + 1;       
			FETCH Spisok INTO @tv; 
		END;   
		print @t;        
	  close Spisok;
    return @rc;
END TRY  
BEGIN CATCH              
	print 'ошибка в параметрах' 
    if error_procedure() is not null   
    print 'имя процедуры : ' + error_procedure();
    return @rc;
END CATCH; 

DECLARE @rc int;
exec @rc = SUBJECT_REPORT @p = 'ИСиТ';
print 'Количество дисциплин на кафедре = ' + convert(varchar(3), @rc);


-- 6. Разработать процедуру с именем PAUDITORI-UM_INSERTX. Процедура принимает пять входных параметров: @a, @n, @c, @t и @tn. 
-- Параметры @a, @n, @c, @t аналогичны парамет-рам процедуры PAUDITORIUM_INSERT. Допол-нительный параметр @tn является входным, имеет тип VARCHAR(50), предназначен для ввода значе-ния в столбец AUDITORI-UM_TYPE.AUDITORIUM_TYPENAME.
-- Процедура добавляет две строки. Первая строка добавляется в таблицу AUDITORIUM_TYPE. Зна-чения столбцов AUDITORIUM_TYPE и AUDITO-RIUM_ TYPENAME добавляемой строки задаются соответственно параметрами @t и @tn. Вторая строка добавляется путем вызова процедуры PAU-DITORIUM_INSERT.
-- Добавление строки в таблицу AUDITORI-UM_TYPE и вызов процедуры PAUDITORI-UM_INSERT должны выполняться в рамках одной явной транзакции с уровнем изолированности SERI-ALIZABLE. 
-- В процедуре должна быть предусмотрена обра-ботка ошибок с помощью механизма TRY/CATCH. Все ошибки должны быть обработаны с выдачей со-ответствующего сообщения в стандартный выходной поток. 
-- Процедура PAUDITORIUM_INSERTX должна возвращать к точке вызова значение -1 в том случае, если произошла ошибка и 1, если выполнения про-цедуры завершилось успешно. 


CREATE PROCEDURE PAUDITORIUM_INSERTX
     @a char(20), @n nvarchar(50), @c int = 0, @t char(10), @tn varchar(50)   
AS DECLARE @rc int = 1;                            
BEGIN TRY
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;          
    BEGIN TRAN
    INSERT INTO AUDITORIUM_TYPE(AUDITORIUM_TYPE, AUDITORIUM_TYPENAME)
                    values (@t, @tn)
    exec @rc = PAUDITORIUM_INSERT @a, @n, @c, @t;  
    commit tran; 
    return @rc;           
END TRY
BEGIN CATCH 
    print 'номер ошибки  : ' + cast(error_number() as varchar(6));
    print 'сообщение     : ' + error_message();
    print 'уровень       : ' + cast(error_severity()  as varchar(6));
    print 'метка         : ' + cast(error_state()   as varchar(8));
    print 'номер строки  : ' + cast(error_line()  as varchar(8));
    if error_procedure() is not  null   
                     print 'имя процедуры : ' + error_procedure();
if @@trancount > 0 rollback tran ; 
     return -1;	  
END CATCH;

declare @rc int;  
exec @rc = PAUDITORIUM_INSERTX @a = '722', @n = '722', @c = 78, @t = 'ЛККК', @tn = 'Лекционная';  
print 'Код ошибки = ' + convert(varchar(3), @rc);  
