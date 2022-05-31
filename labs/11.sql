+-- 1. Разработать сценарий, де-монстрирующий работу в ре-жиме неявной транзакции.
--Проанализировать пример, приведенный справа, в котором создается таблица Х, и создать сценарий для другой таблицы.

set nocount on
if  exists (select * from  SYS.OBJECTS 
         where OBJECT_ID=object_id(N'DBO.TAB')) 
	drop table TAB;           
declare @c int, @flag char = 'r'; -- если с->r, таблица не сохр

SET IMPLICIT_TRANSACTIONS ON -- вкл режим неявной транзакции
	create table TAB(K int );                   
	insert TAB values (1),(2),(3),(4),(5);
	set @c = (select count(*) from TAB);
	print 'кол-во строк в TAB: ' + cast(@c as varchar(2));
	if @flag = 'c' commit  -- фиксация 
		else rollback;     -- откат                           
SET IMPLICIT_TRANSACTIONS OFF -- действует режим автофиксации


if  exists (select * from  SYS.OBJECTS 
          where OBJECT_ID= object_id(N'DBO.TAB')) print 'таблица TAB есть';  
else print 'таблицы TAB нет'

--2
--Разработать сценарий, демонстрирующий свойство атомар-ности явной транзакции на примере базы данных X_UNIVER. 
--В блоке CATCH предусмот-реть выдачу соответствующих сообщений об ошибках. 
--Опробовать работу сценария при использовании различных операторов модификации таб-лиц.

begin try
	begin tran
		insert FACULTY values ('ДФ', 'Факультет других наук');
	    insert FACULTY values ('ПиМ', 'Факультет print-технологий');
	commit tran;
end try
begin catch
	print 'ошибка:'+case
	when error_number()=2627 and patindex('%PK_FASCULTY%', error_message())>0
	then 'дублирование товара'
	else 'неизвестная ошибка'+cast(error_number()as varchar(5))+error_message()
	end;
	if @@TRANCOUNT>0 rollback tran;
	end catch;

--3. Разработать сценарий, де-монстрирующий применение оператора SAVE TRAN на при-мере базы данных X_UNIVER. 
--В блоке CATCH предусмот-реть выдачу соответствующих сообщений об ошибках. 
--Опробовать работу сценария при использовании различных контрольных точек и различных операторов модификации таблиц.

declare @point varchar(32);
begin try
begin tran
	insert FACULTY values('ПсихФак','Факультет Психологии');
	set @point='p1'; save tran @point;
	insert FACULTY values('ЛФ','Факультет Лингвистики');
	set @point='p2' ; save tran @point;
	insert FACULTY values('МФ', 'Медицинский факультет');
	commit tran;
	end try
begin catch
print 'ошибка:'+case when error_number()=2627
and patindex('%PK_FACULTY%',error_message())>0
then 'дублирование товара'
else 'неизвестная ошибка:'+cast(error_number()as varchar(5))
+error_message()
end;
if @@trancount>0
begin 
print 'контрольная точка:'+@point;
rollback tran @point;
commit tran;
end;
end catch;

--4 Разработать два сценария A и B на примере базы данных X_UNIVER. 
--Сценарий A представляет собой явную транзакцию с уров-нем изолированности READ UNCOMMITED, сценарий B – явную транзакцию с уровнем изолированности READ COMMITED (по умолчанию). 
--Сценарий A должен демонстрировать, что уровень READ UNCOMMITED допускает не-подтвержденное, неповторяю-щееся и фантомное чтение. 

----------------A------------------
set transaction isolation level READ UNCOMMITTED
begin transaction
----------------t1-----------------
select @@SPID, 'insert FACULTY' 'результат', *
		from FACULTY WHERE FACULTY = 'ИТ';
	select @@SPID, 'update PULPIT' 'результат', *
		from PULPIT WHERE FACULTY = 'ИТ';
commit;
---------------t2----------------------
----------B--------
begin transaction
select @@SPID 

insert FACULTY values('ФФ','Факультет Физической культуры');
-------------t1---------------------
-------------t2---------------------
rollback;

--5.Разработать два сценария A и B на примере базы данных X_UNIVER. 
--Сценарии A и В  представляют собой явные транзакции с уровнем изолированности READ COMMITED. 
--Сценарий A должен демон-стрировать, что уровень READ COMMITED не допускает не-подтвержденного чтения, но при этом возможно неповторя-ющееся и фантомное чтение. 

--А--
set transaction isolation level READ COMMITTED
begin transaction
select count(*) from FACULTY where FACULTY='ИТ'
--------------t1---------------
--------------t2---------------
select  'update FACULTY' 'результат', count(*)
			from FACULTY where FACULTY='ИТ'
commit;

--B--
begin transaction
------------t1--------------
update FACULTY set FACULTY='ИТ'
where FACULTY='ФИТ'
commit;
------------t2--------------

--6. Разработать два сценария A и B на примере базы данных X_UNIVER. 
--Сценарий A представляет со-бой явную транзакцию с уров-нем изолированности RE-PEATABLE READ. Сценарий B – явную транзакцию с уровнем изолированности READ COM-MITED. 
--Сценарий A должен демон-стрировать, что уровень REAPETABLE READ не допус-кает неподтвержденного чтения и неповторяющегося чтения, но при этом возможно фантомное чтение. 

set transaction isolation level  REPEATABLE READ 
begin transaction 
select PULPIT from PULPIT where FACULTY = 'ИТ';
	-------------------------- t1 ------------------ 
	-------------------------- t2 -----------------
select  case
when PULPIT = 'ЛВ' then 'insert  PULPIT'  else ' ' 
end 'результат', PULPIT from PULPIT  where FACULTY = 'ИТ';
commit; 
	--- B ---	
begin transaction 	  
	-------------------------- t1 --------------------
insert PULPIT values ('пратв', 'Полиграфических производств',  'ИДИП');
commit; 
select * from PULPIT
	-------------------------- t2 --------------------
--7--
-- A ---
set transaction isolation level SERIALIZABLE 
begin transaction 

insert PULPIT values ('КГ', 'Компьютерная графика',  'ИТ');
commit; 
update PULPIT set PULPIT = 'КГ' where FACULTY = 'ИТ';
select PULPIT from PULPIT where FACULTY = 'ИТ';
	-------------------------- t1 -----------------
select PULPIT from PULPIT where FACULTY = 'ИТ';
	-------------------------- t2 ------------------ 
commit; 	

	--- B ---	
begin transaction 	   
insert PULPIT values ('КБ', 'компьютерная безопсность',  'ИТ');
update PULPIT set PULPIT = 'КБ' where FACULTY = 'ИТ';
select PULPIT from PULPIT where FACULTY = 'ИТ';
          -------------------------- t1 --------------------
commit; 
select PULPIT from PULPIT where FACULTY = 'ИТ';
      -------------------------- t2 --------------------
	  select * from PULPIT

--8--
select (select count(*) from dbo.PULPIT where FACULTY = 'ИДиП') 'Кафедры ИДИПа', 
(select count(*) from FACULTY where FACULTY.FACULTY = 'ИДиП') 'ИДИП'; 

select * from PULPIT

begin tran
	begin tran
	update PULPIT set PULPIT_NAME='Кафедра ИДиПа' where PULPIT.FACULTY = 'ИДиП';
	commit;
if @@TRANCOUNT > 0 rollback;
