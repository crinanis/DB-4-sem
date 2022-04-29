--1. Разработать сценарий, формирующий список дисциплин на кафедре ИСиТ. В отчет должны быть выведены краткие названия (поле SUBJECT) из таблицы SUBJECT в одну строку через запятую. 
--Использовать встроенную функцию RTRIM.

USE UNIVER;

DECLARE @out varchar(300) = '', @str char(20)
DECLARE List CURSOR 
			for SELECT SUBJECT from SUBJECT where PULPIT = 'ИСиТ';
	OPEN List
	FETCH List into @str
	print 'Список дисциплин на кафедре:'
	while @@FETCH_STATUS = 0
		begin
		set @out = rtrim(@str) + '; ' + @out
		FETCH List into @str
		end
	print @out
CLOSE List
DEALLOCATE List;

-- 2. Разработать сценарий, демонстрирующий отличие глобального курсора от локального на примере базы данных X_UNIVER.

--LOCAL
DECLARE Marks CURSOR LOCAL
					for SELECT IDSTUDENT, NOTE FROM PROGRESS;
DECLARE @stud int, @note int;
	OPEN Marks;
	fetch Marks into @stud, @note;
	print '1. ' + convert(varchar(5),@stud) + convert(varchar(5),@note);
	go
DECLARE @stud int, @note int;
	fetch Marks into @stud, @note;
	print '2. ' + convert(varchar(5),@stud) + convert(varchar(5),@note);
	go

--GLOBAL

DECLARE Marks CURSOR GLOBAL
					for SELECT IDSTUDENT, NOTE FROM PROGRESS;
DECLARE @stud int, @note int;
	OPEN Marks;
	fetch Marks into @stud, @note;
	print '1. ' + convert(varchar(5),@stud) + convert(varchar(5),@note);
	go
DECLARE @stud int, @note int;
	fetch Marks into @stud, @note;
	print '2. ' + convert(varchar(5),@stud) + convert(varchar(5),@note);
	close Marks;
	deallocate Marks;
	go

-- 3. Разработать сценарий, демонстрирующий отличие статических курсоров от динамических на примере базы данных X_UNIVER.
DECLARE @facult varchar(50), @profession varchar(50), @year int;  
DECLARE Groups_cur CURSOR LOCAL STATIC                              
						for SELECT FACULTY, PROFESSION, YEAR_FIRST FROM GROUPS where Faculty = 'ХТиТ';				   
	open Groups_cur;
	print  'Количество строк : ' + cast(@@CURSOR_ROWS as varchar(5)); 
    UPDATE GROUPS set YEAR_FIRST = 2019 where PROFESSION = '1-36 07 01';
	DELETE GROUPS where IDGROUP = 1;
	
	FETCH  Groups_cur into @facult, @profession, @year;     
	while @@fetch_status = 0     -- до тех пор, пока не закончатся строки                               
      begin 
          print @facult + ' '+ @profession + ' '+ convert(varchar(4),@year);      
          fetch Groups_cur into @facult, @profession, @year; 
       end;          
   CLOSE Groups_cur;


DECLARE @facult1 varchar(50), @profession1 varchar(50), @year1 int;  
DECLARE Groups CURSOR LOCAL DYNAMIC                              
						for SELECT FACULTY, PROFESSION, YEAR_FIRST FROM dbo.GROUPS where Faculty = 'ХТиТ';				   
	open Groups;
	print  'Количество строк : ' + cast(@@CURSOR_ROWS as varchar(5)); 
    UPDATE GROUPS set YEAR_FIRST = 2000 where PROFESSION = '1-36 07 01';
	DELETE GROUPS where IDGROUP = 1;
	
	FETCH  Groups into @facult1, @profession1, @year1;     
	while @@fetch_status = 0                                    
      begin 
          print @facult1 + ' '+ @profession1 + ' '+ convert(varchar(4),@year1);      
          fetch Groups into @facult1, @profession1, @year1; 
       end;          
   CLOSE  Groups;


-- 4. Разработать сценарий, демонстрирующий свойства навигации в резуль-тирующем наборе курсора с атрибутом SCROLL на примере базы данных X_UNIVER.
-- Использовать все известные ключевые слова в операторе FETCH.
 
 DECLARE @prof varchar(20), @faculty varchar(4), @prof_name varchar(40), @qual varchar(30);
 DECLARE Navigation cursor local dynamic SCROLL
										for select row_number() over (order by p.PROFESSION) PROFESSION, p.FACULTY, p.PROFESSION_NAME, p.QUALIFICATION from PROFESSION p;
OPEN Navigation
	FETCH FIRST FROM Navigation into @prof, @faculty, @prof_name, @qual;
	PRINT 'Первая строка: ' + rtrim(@prof)+ '; ' + rtrim(@faculty) + '; ' + rtrim(@prof_name) + '; ' + rtrim(@qual) + '.'; 

	FETCH Navigation into @prof, @faculty, @prof_name, @qual;
	PRINT 'Следующая строка: ' + rtrim(@prof) + '; ' + rtrim(@faculty) + '; ' + rtrim(@prof_name) + '; ' + rtrim(@qual) + '.'; 

	FETCH NEXT FROM Navigation into @prof, @faculty, @prof_name, @qual;
	PRINT 'Следующая строка с помощью next: ' + rtrim(@prof) + '; ' + rtrim(@faculty) + '; ' + rtrim(@prof_name) + '; ' + rtrim(@qual) + '.'; 

	FETCH PRIOR FROM Navigation into @prof, @faculty, @prof_name, @qual;
	PRINT 'Предыдущая строка от текущей: ' + rtrim(@prof) + '; ' + rtrim(@faculty) + '; ' + rtrim(@prof_name) + '; ' + rtrim(@qual) + '.'; 

	FETCH ABSOLUTE 3 FROM Navigation into @prof, @faculty, @prof_name, @qual;
	PRINT 'Третья строка с начала: ' + rtrim(@prof) + '; ' + rtrim(@faculty) + '; ' + rtrim(@prof_name) + '; ' + rtrim(@qual) + '.'; 

	FETCH ABSOLUTE -3 FROM Navigation into @prof, @faculty, @prof_name, @qual;
	PRINT 'Третья строка с конца: ' + rtrim(@prof) + '; ' + rtrim(@faculty) + '; ' + rtrim(@prof_name) + '; ' + rtrim(@qual) + '.'; 

	FETCH RELATIVE 5 FROM Navigation into @prof, @faculty, @prof_name, @qual;
	PRINT 'Пятая строка вперёд от текущей: ' + rtrim(@prof) + '; ' + rtrim(@faculty) + '; ' + rtrim(@prof_name) + '; ' + rtrim(@qual) + '.'; 

	FETCH RELATIVE -5 FROM Navigation into @prof, @faculty, @prof_name, @qual;
	PRINT 'Пятая строка назад от текущей: ' + rtrim(@prof) + '; ' + rtrim(@faculty) + '; ' + rtrim(@prof_name) + '; ' + rtrim(@qual) + '.'; 
CLOSE Navigation;
DEALLOCATE Navigation;


-- 5. Создать курсор, демонстрирующий применение конструкции CURRENT OF в секции WHERE с использованием операторов UPDATE и DELETE.

DECLARE @aud varchar(10), @a_type varchar(10), @cap int;
DECLARE Aud_cur CURSOR GLOBAL DYNAMIC 
							FOR SELECT a.AUDITORIUM, a.AUDITORIUM_TYPE, a.AUDITORIUM_CAPACITY FROM AUDITORIUM a FOR UPDATE;
OPEN Aud_cur;
	FETCH Aud_cur INTO @aud, @a_type, @cap;
	PRINT 'Selected row for update: ' + rtrim(@aud) + ', ' + rtrim(@a_type) + ', ' + convert(varchar(5), @cap) + '.';
	UPDATE AUDITORIUM SET AUDITORIUM_CAPACITY = AUDITORIUM_CAPACITY + 1 WHERE CURRENT OF Aud_cur;

	FETCH Aud_cur INTO @aud, @a_type, @cap;
	PRINT 'Selected row for delete: ' + rtrim(@aud) + ', ' + rtrim(@a_type) + ', ' + convert(varchar(5), @cap) + '.';
	DELETE AUDITORIUM WHERE CURRENT OF Aud_cur;
CLOSE Aud_cur;
DEALLOCATE Aud_cur;


-- 6.1. Разработать SELECT-запрос, с помощью которого из таблицы PROGRESS удаляются строки, содержащие информацию о студентах,
-- получивших оценки ниже 4 (использовать объединение таблиц PROGRESS, STUDENT, GROUPS). 

DECLARE @id varchar(5), @nme varchar(10), @nte int;
DECLARE Stud_cur CURSOR GLOBAL DYNAMIC 
							FOR SELECT p.IDSTUDENT, s.NAME, p.NOTE FROM PROGRESS p
								JOIN STUDENT s ON s.IDSTUDENT = p.IDSTUDENT WHERE p.NOTE < 4 FOR UPDATE;
OPEN Stud_cur;
	FETCH Stud_cur INTO @id, @nme, @nte;
	PRINT 'Selected row: ' + @id + ', ' + rtrim(@nme) + ', ' + convert(varchar(5), @nte) + '.';
	DELETE PROGRESS WHERE CURRENT OF Stud_cur;
	DELETE STUDENT WHERE CURRENT OF Stud_cur;

CLOSE Stud_cur;
DEALLOCATE Stud_cur;


-- 6.2. Разработать SELECT-запрос, с помощью которого в таблице PROGRESS для студента с конкретным номером IDSTUDENT корректируется оценка (увеличивается на единицу).

DECLARE @i varchar(5), @nm varchar(30), @nt int;
DECLARE Stud_cur CURSOR GLOBAL DYNAMIC 
							FOR SELECT p.IDSTUDENT, s.NAME, p.NOTE FROM PROGRESS p
								JOIN STUDENT s ON s.IDSTUDENT = p.IDSTUDENT WHERE p.IDSTUDENT = 1003 FOR UPDATE;
OPEN Stud_cur;
	FETCH Stud_cur INTO @i, @nm, @nt;
	PRINT 'Selected row: ' + @i + ', ' + rtrim(@nm) + ', текущая оценка: ' +convert(varchar(5), @nt) + '.';
	UPDATE PROGRESS SET NOTE = NOTE + 1 WHERE CURRENT OF Stud_cur;

CLOSE Stud_cur;
DEALLOCATE Stud_cur;


DECLARE @stud_id varchar(5), @stud_name varchar(30), @stud_note int;
DECLARE Cur CURSOR LOCAL DYNAMIC SCROLL
								for select row_number() over (order by p.IDSTUDENT) IDSTUDENT, s.NAME, p.NOTE from PROGRESS p
																												JOIN STUDENT s on s.IDSTUDENT = p.IDSTUDENT;
OPEN Cur
	FETCH NEXT FROM Cur into @stud_id, @stud_name, @stud_note;

DECLARE @note1 int, @note2 int, @name1 varchar(30), @name2 varchar(30);

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @note1 = @stud_note;
	SET @name1 = @stud_name;
	FETCH NEXT FROM Cur into @stud_id, @stud_name, @stud_note;
	SET @note2 = @stud_note;
	SET @name2 = @stud_name;
	IF (@note2 > @note1) PRINT 'Note of ' + @name2 + '(' + convert(varchar(5), @note2) + ')' + ' is better than note of ' + @name1 + '(' + convert(varchar(5),  @note1) + ')'
	ELSE IF (@note2 < @note1) PRINT 'Note of ' + @name2 + '(' + convert(varchar(5), @note2) + ')' + ' is worse than note of ' + @name1 + '(' + convert(varchar(5), @note1) + ')'
END



CLOSE Cur;
DEALLOCATE Cur;