use UNIVER;
use tempdb;

-- 1. � ������� SSMS ���������� ��� �������, ������� ������� � �� UNIVER. ����������, ����� �� ��� �������� �����������������, � ����� �������������������. 
--������� ��������� ��������� �������. ��������� �� ������� (�� ����� 1000 �����). 
--����������� SELECT-������. �������� ���� ������� � ���������� ��� ���������. 
--������� ���������������� ������, ����������� ��������� SELECT-�������.

exec sp_helpindex 'AUDITORIUM'
exec sp_helpindex 'FACULTY'	--�������� ��������, ����. � �-� ��������
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

SET nocount on; --�� �������� ��������� � ����� �����
DECLARE @i int=0
WHILE @i<1001
begin 
	Insert #EXPLRE(TIND, TFIELD)
			values(floor(20000*rand()),REPLICATE('������', 10)); 
	If(@i%100=0) print @i;
	set @i=@i+1;
	end;
select * from #EXPLRE where TIND between 1500 and 5000 order by TIND 
	checkpoint;				--�������� ��
	DBCC DROPCLEANBUFFERS;	--�������� �������� ���

CREATE clustered index #EXPLRE_cl on #EXPLRE(TIND asc)


-- 2. ������� ��������� ��������� �������. ��������� �� ������� (10000 ����� ��� ������). 
--����������� SELECT-������. �������� ���� ������� � ���������� ��� ���������. 
-- ������� ������������������ ������������ ��������� ������. 
-- ������� ��������� ������ ����������.

Create table #EX
(
TKEY int,
CC int identity(1,1),
TF varchar(100));

set nocount on;
declare @i2 int=0;
while @i2<10000
begin 
	INSERT #EX(TKEY,TF) values(floor(30000*RAND()), replicate('������',10))
	set @i2=@i2+1;
	end

Select count(*)[���������� �����] from #EX;
Select *from #EX

create index #EX_NONCLU on #EX(TKEY,CC)--�������� ��������� ������������ ������������������ ������

Select* from #EX where TKEY=1500 and CC<4500;
Select *from #EX order by TKEY,CC
drop table #EX

-- 3. ������� ��������� ��������� �������. ��������� �� ������� (�� ����� 10000 �����). 
-- ����������� SELECT-������. �������� ���� ������� � ���������� ��� ���������. 
-- ������� ������������������ ������ ��������, ����������� ��������� SELECT-�������. 

Create table #EX_3
(
TKEY_3 int,
CC_3 int identity(1,1),
TF_3 varchar(100));

set nocount on;
declare @i3 int=0;
while @i3<10001
begin 
	INSERT #EX_3(TKEY_3,TF_3) values(floor(30000*RAND()), replicate('������',10))
	set @i3=@i3+1;
	end

Select count(*)[���������� �����] from #EX_3;
Select *from #EX_3

Create index #EX_TKEY_X on #EX_3(TKEY_3) INCLUDE(CC_3) 
Select CC_3 from #EX_3 where TKEY_3>1500;

-- 4. ������� � ��������� ��������� ��������� �������. 
-- ����������� SELECT-������, �������� ���� ������� � ���������� ��� ���������. 
-- ������� ������������������ ����������� ������, ����������� ��������� SELECT-�������.

Create table #EX_4
(
TKEY_4 int,
CC_4 int identity(1,1),
TF_4 varchar(100));

set nocount on;
declare @i4 int=0;
while @i4<10001
begin 
	INSERT #EX_4(TKEY_4,TF_4) values(floor(30000*RAND()), replicate('������',10))
	set @i4=@i4+1;
	end

select TKEY_4 from #EX_4 where TKEY_4 between 5000 and 19999;
select TKEY_4 from #EX_4 where TKEY_4>15000 and TKEY_4<20000;
select TKEY_4 from #EX_4 where TKEY_4=17000

create index #EX_WHERE on #EX_4(TKEY_4) where (TKEY_4>=15000 and TKEY_4<20000)

select TKEY_4 from #EX_4 where TKEY_4 between 5000 and 19999;
select TKEY_4 from #EX_4 where TKEY_4>15000 and TKEY_4<20000;
select TKEY_4 from #EX_4 where TKEY_4=17000

-- 5. ��������� ��������� ��������� �������. 
-- ������� ������������������ ������. ������� ������� ������������ �������. 
-- ����������� �������� �� T-SQL, ���������� �������� �������� � ������ ������������ ������� ���� 90%. ������� ������� ������������ �������. 
-- ��������� ��������� ������������� �������, ������� ������� ������������. 
-- ��������� ��������� ����������� ������� � ������� ������� ������������ �������.

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
	INSERT #EX_5(TKEY_5,TF_5) values(floor(30000*RAND()), replicate('������',10))
	set @i5=@i5+1;
	end

CREATE index #EX5_ind  on #EX_5(TKEY_5);

SELECT	name [������],
		avg_fragmentation_in_percent [������������(%)] 
	FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'), 
  OBJECT_ID(N'#EX_5'), NULL, NULL, NULL) ss
  JOIN sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id 
  where name is not null;

INSERT top(100000) #EX_5(TKEY_5, TF_5) select TKEY_5, TF_5 from #EX_5;

ALTER index #EX5_ind on #EX_5 reorganize; 
ALTER index #EX5_ind  on #EX_5 rebuild with (online = off);

drop index #EX5_ind on #EX_5

-- 6. ����������� ������, ��������������� ���������� ��������� FILLFACTOR ��� �������� ������������������� �������.
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
	INSERT #EX_6(TKEY_6,TF_6) values(floor(30000*RAND()), replicate('������',10))
	set @i6=@i6+1;
	end
CREATE index #EX6_ind  on #EX_6(TKEY_6) with(fillfactor=65);
INSERT top(100000) #EX_6(TKEY_6, TF_6) select TKEY_6, TF_6 from #EX_6;

SELECT	name [������],
		avg_fragmentation_in_percent [������������(%)] 
	FROM sys.dm_db_index_physical_stats(DB_ID(N'TEMPDB'), 
  OBJECT_ID(N'#EX_5'), NULL, NULL, NULL) ss
  JOIN sys.indexes ii on ss.object_id = ii.object_id and ss.index_id = ii.index_id 
  where name is not null;


