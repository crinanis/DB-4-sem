use UNIVER;
use tempdb;

-- 1. С помощью SSMS определить все индексы, которые имеются в БД UNIVER. Определить, какие из них являются кластеризованными, а какие некластеризованными. 
--Создать временную локальную таблицу. Заполнить ее данными (не менее 1000 строк). 
--Разработать SELECT-запрос. Получить план запроса и определить его стоимость. 
--Создать кластеризованный индекс, уменьшающий стоимость SELECT-запроса.

exec sp_helpindex 'AUDITORIUM'
exec sp_helpindex 'FACULTY'	--перечень индексов, связ. с д-й таблицей
exec sp_helpindex 'GROUPS'
exec sp_helpindex 'PROFESSION'
exec sp_helpindex 'PROGRESS'
exec sp_helpindex 'PULPIT'

--set statistics io off
--set statistics time off

create table #EXPLRE
( TIND int,
TFIELD varchar(100)
);

SET nocount on; --не выводить сообщения о вводе строк
DECLARE @i int=0
WHILE @i<1001
begin 
	Insert #EXPLRE(TIND, TFIELD)
			values(floor(20000*rand()),REPLICATE('строка', 10)); 
	If(@i%100=0) print @i;
	set @i=@i+1;
	end;
select * from #EXPLRE where TIND between 1500 and 5000 order by TIND 
	checkpoint;				--фиксация БД
	DBCC DROPCLEANBUFFERS;	--очистить буферный кэш

CREATE clustered index #EXPLRE_cl on #EXPLRE(TIND asc)


-- 2. Создать временную локальную таблицу. Заполнить ее данными (10000 строк или больше). 
--Разработать SELECT-запрос. Получить план запроса и определить его стоимость. 
-- Создать некластеризованный неуникальный составной индекс. 
-- Оценить процедуры поиска информации.

Create table #EX
(
TKEY int,
CC int identity(1,1),
TF varchar(100));

set nocount on;
declare @i2 int=0;
while @i2<10000
begin 
	INSERT #EX(TKEY,TF) values(floor(30000*RAND()), replicate('строка',10))
	set @i2=@i2+1;
	end

Select count(*)[количество строк] from #EX;
Select *from #EX

create index #EX_NONCLU on #EX(TKEY,CC)--создание составной неуникальной некластеризованный индекс

Select* from #EX where TKEY=1500 and CC<4500;
Select *from #EX order by TKEY,CC
drop table #EX

-- 3. Создать временную локальную таблицу. Заполнить ее данными (не менее 10000 строк). 
-- Разработать SELECT-запрос. Получить план запроса и определить его стоимость. 
-- Создать некластеризованный индекс покрытия, уменьшающий стоимость SELECT-запроса. 

Create table #EX_3
(
TKEY_3 int,
CC_3 int identity(1,1),
TF_3 varchar(100));

set nocount on;
declare @i3 int=0;
while @i3<10001
begin 
	INSERT #EX_3(TKEY_3,TF_3) values(floor(30000*RAND()), replicate('строка',10))
	set @i3=@i3+1;
	end

Select count(*)[количество строк] from #EX_3;
Select *from #EX_3

Create index #EX_TKEY_X on #EX_3(TKEY_3) INCLUDE(CC_3) 
Select CC_3 from #EX_3 where TKEY_3>1500;

-- 4. Создать и заполнить временную локальную таблицу. 
-- Разработать SELECT-запрос, получить план запроса и определить его стоимость. 
-- Создать некластеризованный фильтруемый индекс, уменьшающий стоимость SELECT-запроса.

Create table #EX_4
(
TKEY_4 int,
CC_4 int identity(1,1),
TF_4 varchar(100));

set nocount on;
declare @i4 int=0;
while @i4<10001
begin 
	INSERT #EX_4(TKEY_4,TF_4) values(floor(30000*RAND()), replicate('строка',10))
	set @i4=@i4+1;
	end

select TKEY_4 from #EX_4 where TKEY_4 between 5000 and 19999;
select TKEY_4 from #EX_4 where TKEY_4>15000 and TKEY_4<20000;
select TKEY_4 from #EX_4 where TKEY_4=17000

create index #EX_WHERE on #EX_4(TKEY_4) where (TKEY_4>=15000 and TKEY_4<20000)

select TKEY_4 from #EX_4 where TKEY_4 between 5000 and 19999;
select TKEY_4 from #EX_4 where TKEY_4>15000 and TKEY_4<20000;
select TKEY_4 from #EX_4 where TKEY_4=17000

-- 5. Заполнить временную локальную таблицу. 
-- Создать некластеризованный индекс. Оценить уровень фрагментации индекса. 
-- Разработать сценарий на T-SQL, выполнение которого приводит к уровню фрагментации индекса выше 90%. Оценить уровень фрагментации индекса. 
-- Выполнить процедуру реорганизации индекса, оценить уровень фрагментации. 
-- Выполнить процедуру перестройки индекса и оценить уровень фрагментации индекса.

Create table #EX_5
(
TKEY_5 int,
CC_5 int identity(1,1),
TF_5 varchar(100)
);
set nocount on;
declare @i5 int=0;
while @i5<10001
begin 
	INSERT #EX_5(TKEY_5,TF_5) values(floor(30000*RAND()), replicate('строка',10))
	set @i5=@i5+1;
	end

CREATE index #EX5_ind  on #EX_5(TKEY_5);

SELECT	name [Индекс],
		avg_fragmentation_in_percent [Фрагментация(%)] 
	FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'), 
  OBJECT_ID(N'#EX_5'), NULL, NULL, NULL) ss
  JOIN sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id 
  where name is not null;

INSERT top(100000) #EX_5(TKEY_5, TF_5) select TKEY_5, TF_5 from #EX_5;

ALTER index #EX5_ind on #EX_5 reorganize; 
ALTER index #EX5_ind  on #EX_5 rebuild with (online = off);

drop index #EX5_ind on #EX_5

-- 6. Разработать пример, демонстрирующий применение параметра FILLFACTOR при создании некластеризованного индекса.
Create table #EX_6
(
TKEY_6 int,
CC_6 int identity(1,1),
TF_6 varchar(100)
);
set nocount on;
declare @i6 int=0;
while @i6<10001
begin 
	INSERT #EX_6(TKEY_6,TF_6) values(floor(30000*RAND()), replicate('строка',10))
	set @i6=@i6+1;
	end
CREATE index #EX6_ind  on #EX_6(TKEY_6) with(fillfactor=65);
INSERT top(100000) #EX_6(TKEY_6, TF_6) select TKEY_6, TF_6 from #EX_6;

SELECT	name [Индекс],
		avg_fragmentation_in_percent [Фрагментация(%)] 
	FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'), 
  OBJECT_ID(N'#EX_5'), NULL, NULL, NULL) ss
  JOIN sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id 
  where name is not null;


