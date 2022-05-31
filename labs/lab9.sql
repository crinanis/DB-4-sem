-- 1. С помощью SSMS определить все индексы, которые имеются в БД UNIVER. Определить, какие из них являются кластеризованными, а ка-кие некластеризованными. 
-- Создать временную локальную таблицу. Заполнить ее данными (не менее 1000 строк). 
-- Разработать SELECT-запрос. Получить план запроса и определить его стоимость. 
-- Создать кластеризованный индекс, уменьшающий стоимость SELECT-запроса.

exec sp_helpindex 'AUDITORIUM';
exec sp_helpindex 'AUDITORIUM_TYPE';
exec sp_helpindex 'FACULTY';
exec sp_helpindex 'GROUPS';
exec sp_helpindex 'PROFESSION';
exec sp_helpindex 'PROGRESS';
exec sp_helpindex 'PULPIT';
exec sp_helpindex 'STUDENT';
exec sp_helpindex 'SUBJECT';
exec sp_helpindex 'TEACHER';

CREATE TABLE #EXPLRE
(	TIND int,
	TFIELD varchar(100)
);

SET nocount on; --не выводить сообщения о выводе строк
DECLARE @i int = 0;
WHILE @i<1000
	BEGIN
		INSERT #EXPLRE(TIND, TFIELD)
			VALUES(floor(20000*RAND()), REPLICATE('строка',10));
		IF(@i%100=0) print @i;
		SET @i=@i+1;
	END;

SELECT * FROM #EXPLRE where TIND between 1500 and 2500 order by TIND;

checkpoint;
DBCC DROPCLEANBUFFERS;

CREATE clustered index #EXPLRE_CL on #EXPLRE(TIND asc)

-- 2. Создать временную локальную таблицу. Заполнить ее данными (10000 строк или больше). 
-- Разработать SELECT-запрос. Получить план запроса и определить его стоимость. 
-- Создать некластеризованный неуникальный составной индекс. 
-- Оценить процедуры поиска информации.

CREATE table #EX
(	TKEY int, 
    CC int identity(1, 1),
    TF varchar(100)
)

set nocount on;           
declare @ii int = 0;
while   @ii < 20000       -- добавление в таблицу 20000 строк
  begin
       INSERT #EX(TKEY, TF) values(floor(30000*RAND()), replicate('строка ', 10));
        set @ii = @ii + 1; 
  end;

  SELECT count(*)[количество строк] from #EX;
  SELECT * from #EX

  -- составной индекс
  CREATE INDEX #EX_NONCLU ON #EX(TKEY, CC)

  SELECT * from  #EX where  TKEY > 1500 and  CC < 4500;  
  SELECT * from  #EX order by  TKEY, CC

  -- фиксируем значение, чтобы оптимизатор применил индекс
  SELECT * from  #EX where  TKEY = 556 and  CC > 3


  -- 3. Создать временную локальную таблицу. Заполнить ее данными (не менее 10000 строк). 
-- Разработать SELECT-запрос. Получить план запроса и определить его стоимость. 
-- Создать некластеризованный индекс покрытия, уменьшающий стоимость SELECT-запроса. 

CREATE table #EX2
(	TKEY int, 
    CC int identity(1, 1),
    TF varchar(100)
)
set nocount on;           
declare @it int = 0;
while   @it < 20000       -- добавление в таблицу 20000 строк
  begin
       INSERT #EX2(TKEY, TF) values(floor(30000*RAND()), replicate('строка ', 10));
        set @it = @it + 1; 
  end;
  
SELECT CC from #EX2 where TKEY>15000 

CREATE INDEX #EX_TKEY_X ON #EX2(TKEY) INCLUDE(CC)


-- 4. Создать и заполнить временную локальную таблицу. 
-- Разработать SELECT-запрос, получить план запроса и определить его стоимость. 
-- Создать некластеризованный фильтруемый индекс, уменьшающий стоимость SELECT-запроса.


CREATE TABLE #EX4
(
	TKEY4 INT,
	CC4 int identity(1,1),
	TF4 varchar(100)
)
set nocount on;           
declare @i4 int = 0;
while   @i4 < 20000       -- добавление в таблицу 20000 строк
  begin
       INSERT #EX2(TKEY, TF) values(floor(30000*RAND()), replicate('строка ', 10));
        set @i4 = @i4 + 1; 
  end;

SELECT TKEY4 from  #EX4 where TKEY4 between 5000 and 19999; 
SELECT TKEY4 from  #EX4 where TKEY4 > 15000 and  TKEY4 < 20000; 
SELECT TKEY4 from  #EX4 where TKEY4 = 17000;

CREATE INDEX #EX_WHERE on #EX4(TKEY4) WHERE (TKEY4 >= 15000 and TKEY4 < 20000)

-- 5. Заполнить временную локальную таблицу. 
-- Создать некластеризованный индекс. Оценить уровень фрагментации индекса. 
-- Разработать сценарий на T-SQL, выполнение которого приводит к уровню фрагментации индекса выше 90%. Оценить уровень фрагментации индекса. 
-- Выполнить процедуру реорганизации индекса, оценить уровень фрагментации. 
-- Выполнить процедуру перестройки индекса и оценить уровень фрагментации индекса.
