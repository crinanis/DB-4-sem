+-- 1. ����������� ��������, ��-������������� ������ � ��-���� ������� ����������.
--���������������� ������, ����������� ������, � ������� ��������� ������� �, � ������� �������� ��� ������ �������.

set nocount on
if  exists (select * from  SYS.OBJECTS 
         where OBJECT_ID=object_id(N'DBO.TAB')) 
	drop table TAB;           
declare @c int, @flag char = 'r'; -- ���� �->r, ������� �� ����

SET IMPLICIT_TRANSACTIONS ON -- ��� ����� ������� ����������
	create table TAB(K int );                   
	insert TAB values (1),(2),(3),(4),(5);
	set @c = (select count(*) from TAB);
	print '���-�� ����� � TAB: ' + cast(@c as varchar(2));
	if @flag = 'c' commit  -- �������� 
		else rollback;     -- �����                           
SET IMPLICIT_TRANSACTIONS OFF -- ��������� ����� ������������


if  exists (select * from  SYS.OBJECTS 
          where OBJECT_ID= object_id(N'DBO.TAB')) print '������� TAB ����';  
else print '������� TAB ���'

--2
--����������� ��������, ��������������� �������� ������-����� ����� ���������� �� ������� ���� ������ X_UNIVER. 
--� ����� CATCH ���������-���� ������ ��������������� ��������� �� �������. 
--���������� ������ �������� ��� ������������� ��������� ���������� ����������� ���-���.

begin try
	begin tran
		insert FACULTY values ('��', '��������� ������ ����');
	    insert FACULTY values ('���', '��������� print-����������');
	commit tran;
end try
begin catch
	print '������:'+case
	when error_number()=2627 and patindex('%PK_FASCULTY%', error_message())>0
	then '������������ ������'
	else '����������� ������'+cast(error_number()as varchar(5))+error_message()
	end;
	if @@TRANCOUNT>0 rollback tran;
	end catch;

--3. ����������� ��������, ��-������������� ���������� ��������� SAVE TRAN �� ���-���� ���� ������ X_UNIVER. 
--� ����� CATCH ���������-���� ������ ��������������� ��������� �� �������. 
--���������� ������ �������� ��� ������������� ��������� ����������� ����� � ��������� ���������� ����������� ������.

declare @point varchar(32);
begin try
begin tran
	insert FACULTY values('�������','��������� ����������');
	set @point='p1'; save tran @point;
	insert FACULTY values('��','��������� �����������');
	set @point='p2' ; save tran @point;
	insert FACULTY values('��', '����������� ���������');
	commit tran;
	end try
begin catch
print '������:'+case when error_number()=2627
and patindex('%PK_FACULTY%',error_message())>0
then '������������ ������'
else '����������� ������:'+cast(error_number()as varchar(5))
+error_message()
end;
if @@trancount>0
begin 
print '����������� �����:'+@point;
rollback tran @point;
commit tran;
end;
end catch;

--4 ����������� ��� �������� A � B �� ������� ���� ������ X_UNIVER. 
--�������� A ������������ ����� ����� ���������� � ����-��� ��������������� READ UNCOMMITED, �������� B � ����� ���������� � ������� ��������������� READ COMMITED (�� ���������). 
--�������� A ������ ���������������, ��� ������� READ UNCOMMITED ��������� ��-��������������, ����������-����� � ��������� ������. 

----------------A------------------
set transaction isolation level READ UNCOMMITTED
begin transaction
----------------t1-----------------
select @@SPID, 'insert FACULTY' '���������', *
		from FACULTY WHERE FACULTY = '��';
	select @@SPID, 'update PULPIT' '���������', *
		from PULPIT WHERE FACULTY = '��';
commit;
---------------t2----------------------
----------B--------
begin transaction
select @@SPID 

insert FACULTY values('��','��������� ���������� ��������');
-------------t1---------------------
-------------t2---------------------
rollback;

--5.����������� ��� �������� A � B �� ������� ���� ������ X_UNIVER. 
--�������� A � �  ������������ ����� ����� ���������� � ������� ��������������� READ COMMITED. 
--�������� A ������ �����-����������, ��� ������� READ COMMITED �� ��������� ��-��������������� ������, �� ��� ���� �������� ���������-������ � ��������� ������. 

--�--
set transaction isolation level READ COMMITTED
begin transaction
select count(*) from FACULTY where FACULTY='��'
--------------t1---------------
--------------t2---------------
select  'update FACULTY' '���������', count(*)
			from FACULTY where FACULTY='��'
commit;

--B--
begin transaction
------------t1--------------
update FACULTY set FACULTY='��'
where FACULTY='���'
commit;
------------t2--------------

--6. ����������� ��� �������� A � B �� ������� ���� ������ X_UNIVER. 
--�������� A ������������ ��-��� ����� ���������� � ����-��� ��������������� RE-PEATABLE READ. �������� B � ����� ���������� � ������� ��������������� READ COM-MITED. 
--�������� A ������ �����-����������, ��� ������� REAPETABLE READ �� �����-���� ����������������� ������ � ���������������� ������, �� ��� ���� �������� ��������� ������. 

set transaction isolation level  REPEATABLE READ 
begin transaction 
select PULPIT from PULPIT where FACULTY = '��';
	-------------------------- t1 ------------------ 
	-------------------------- t2 -----------------
select  case
when PULPIT = '��' then 'insert  PULPIT'  else ' ' 
end '���������', PULPIT from PULPIT  where FACULTY = '��';
commit; 
	--- B ---	
begin transaction 	  
	-------------------------- t1 --------------------
insert PULPIT values ('�����', '��������������� �����������',  '����');
commit; 
select * from PULPIT
	-------------------------- t2 --------------------
--7--
-- A ---
set transaction isolation level SERIALIZABLE 
begin transaction 

insert PULPIT values ('��', '������������ �������',  '��');
commit; 
update PULPIT set PULPIT = '��' where FACULTY = '��';
select PULPIT from PULPIT where FACULTY = '��';
	-------------------------- t1 -----------------
select PULPIT from PULPIT where FACULTY = '��';
	-------------------------- t2 ------------------ 
commit; 	

	--- B ---	
begin transaction 	   
insert PULPIT values ('��', '������������ �����������',  '��');
update PULPIT set PULPIT = '��' where FACULTY = '��';
select PULPIT from PULPIT where FACULTY = '��';
          -------------------------- t1 --------------------
commit; 
select PULPIT from PULPIT where FACULTY = '��';
      -------------------------- t2 --------------------
	  select * from PULPIT

--8--
select (select count(*) from dbo.PULPIT where FACULTY = '����') '������� �����', 
(select count(*) from FACULTY where FACULTY.FACULTY = '����') '����'; 

select * from PULPIT

begin tran
	begin tran
	update PULPIT set PULPIT_NAME='������� �����' where PULPIT.FACULTY = '����';
	commit;
if @@TRANCOUNT > 0 rollback;
