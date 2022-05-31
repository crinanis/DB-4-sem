CREATE TABLE TR_AUDIT
(
	ID int identity,	--�����
	STMT varchar(20)	--DML_��������
		check (STMT in('INS','DEL','UPD')),
	TRANAME varchar(50),--��� ��������
	CC varchar(300)	--�����������
)

-- 1. ����������� AFTER-������� � ������ TR_TEACHER_INS ��� ������� TEACHER, ����������� �� ������� INSERT. 
-- ������� ������ ���������� ������ �������� ������ � ������� TR_AUDIT. � ������� �� ���������� �������� �������� �������� ������.

CREATE TRIGGER TR_TEACHER_INS ON TEACHER AFTER INSERT
AS
DECLARE @teacher varchar(20), @nme varchar(100), @gender varchar(1), @pulp varchar(100), @res varchar(300)
print '�������� �������';
set @teacher = (select TEACHER from INSERTED);
set @nme = (select TEACHER_NAME from INSERTED);
set @gender = (select GENDER from INSERTED);
set @pulp = (select PULPIT from INSERTED);
set @res = @teacher + ' ' + @nme + ' '+ @gender + ' ' + @pulp;
INSERT INTO TR_AUDIT(STMT,TRANAME,CC) 
				values('INS','TR_TEACHER_INS', @res);
return;


INSERT INTO TEACHER values('����', '������ ���� ��������', '�', '����');
SELECT * FROM TR_AUDIT
	 
	 
-- 2. ������� AFTER-������� � ������ TR_TEACHER_DEL ��� ������� TEACHER, ����������� �� ������� DELETE. 
-- ������� ������ ���������� ������ ������ � ������� TR_AUDIT ��� ������ ��������� ������. 
-- � ������� �� ���������� �������� ������� TEACHER ��������� ������. 

CREATE TRIGGER T_TEACHER_DEL ON TEACHER AFTER DELETE
AS
DECLARE @teacher varchar(20), @nme varchar(100), @gender varchar(1), @pulp varchar(100), @res varchar(300)
SET @teacher = (SELECT TEACHER FROM deleted);
SET @nme = (SELECT TEACHER_NAME FROM deleted);
SET @gender = (SELECT GENDER FROM deleted);
SET @pulp = (SELECT PULPIT FROM deleted);
SET @res = @teacher + ' ' + @nme + ' ' + @gender + ' ' + @pulp;
INSERT INTO TR_AUDIT(STMT, TRANAME, CC) 
				VALUES ('DEL', 'T_TEACHER_DEL', @res);


DELETE FROM TEACHER WHERE TEACHER = '����';
SELECT * FROM TR_AUDIT;


 -- 3. ������� AFTER-������� � ������ TR_TEACHER_UPD ��� ������� TEACHER, ����������� �� ������� UPDATE. 
 -- ������� ������ ���������� ������ ������ � ������� TR_AUDIT ��� ������ ���������� ������. 
 -- � ������� �� ���������� �������� �������� ���������� ������ �� � ����� ���������.

CREATE TRIGGER TR_TEACHER_UPD ON TEACHER AFTER UPDATE
AS
DECLARE @teacher varchar(20), @nme varchar(100), @gender varchar(1), @pulp varchar(100), @res varchar(300)
 print '�������� ����������';
      set @teacher = (select TEACHER from INSERTED);
      set @nme= (select TEACHER_NAME from INSERTED);
      set @gender= (select GENDER from INSERTED);
	  set @pulp = (select PULPIT from INSERTED);
      set @res = @teacher + ' '+ @nme + ' '+ @gender + ' ' + @pulp;
      set @teacher = (select TEACHER from DELETED);
      set @nme= (select TEACHER_NAME from DELETED);
      set @gender= (select GENDER from DELETED);
	  set @pulp = (select PULPIT from DELETED);
      set @res = @res + '' + @teacher + ' '+ @nme + ' '+ @gender + ' ' + @pulp;
      INSERT INTO TR_AUDIT(STMT, TRANAME, CC)  
                            values('UPD', 'TR_TEACHER_UPD', @res);	         
      return;  

UPDATE TEACHER SET GENDER = '�' WHERE TEACHER='����'
SELECT * FROM TR_AUDIT;


-- 4. ������� AFTER-������� � ������ TR_TEACHER ��� ������� TEACHER, ����������� �� ������� INSERT, DELETE, UPDATE. 
-- ������� ������ ���������� ������ ������ � ������� TR_AUDIT ��� ������ ���������� ������. � ���� �������� ���������� �������,
-- ���������������� ������� � ��������� � ������� �� ��������������� ������� ����������. 
-- ����������� ��������, ��������������� ����������������� ��������. 

CREATE TRIGGER TR_TEACHER ON TEACHER AFTER INSERT, DELETE, UPDATE
AS
DECLARE @teacher varchar(20), @nme varchar(100), @gender varchar(1), @pulp varchar(100), @res varchar(300)

DECLARE @ins int = (select count(*) from inserted), @del int = (select count(*) from deleted);
	if @ins > 0 and @del = 0
		begin 
		print '������� ����������';
		set @teacher=(select TEACHER from INSERTED);
		set @nme=(select TEACHER_NAME from INSERTED);
		set @gender=(select GENDER from INSERTED);
		set @pulp=(select	PULPIT from INSERTED);
		set @res = @teacher + ' '+ @nme + ' '+ @gender + ' ' + @pulp;
		insert into TR_AUDIT(STMT,TRANAME,CC) 
				values('INS','TR_TEACHER_INS',@res);
		end;
	else if	@ins = 0 and @del > 0
		begin 
			print '�������� ��������'
			set @teacher=(select TEACHER from deleted);
			set @nme=(select TEACHER_NAME from deleted);
			set @gender=(select GENDER from deleted);
			set @pulp=(select	PULPIT from deleted);
			set @res = @teacher + ' '+ @nme + ' '+ @gender + ' ' + @pulp;
			insert into TR_AUDIT(STMT,TRANAME,CC) 
					values('DEL','TR_TEACHER_DEL', @res);
		end;
	else if @ins > 0 and @del > 0
		begin 
			  print '�������� ����������';
			  set @teacher = (select TEACHER from INSERTED);
			  set @nme= (select TEACHER_NAME from INSERTED);
			  set @gender= (select GENDER from INSERTED);
			  set @pulp= (select PULPIT from INSERTED);
			 set @res = @teacher + ' '+ @nme + ' '+ @gender + ' ' + @pulp;
			  set @teacher = (select TEACHER from deleted);
			  set @nme= (select TEACHER_NAME from DELETED);
			  set @gender= (select GENDER from DELETED);
			  set @pulp = (select PULPIT from DELETED);
			  set @res = @teacher + ' '+ @nme + ' '+ @gender + ' ' + @pulp;
			  insert into TR_AUDIT(STMT, TRANAME, CC)  
									values('UPD', 'TR_TEACHER_UPD', @res);	         
		end;
return;  


UPDATE TEACHER SET GENDER = '�' WHERE TEACHER='����'
DELETE FROM TEACHER WHERE TEACHER = '����';
INSERT INTO TEACHER values('����', '������ ���� ��������', '�', '����');
SELECT * FROM TR_AUDIT;

-- 5. ����������� ��������, ������� �����-�������� �� ������� ���� ������ X_UNIVER, 
-- ��� �������� ����������� ��-��������� ����������� �� ������������ AF-TER-��������.

UPDATE TEACHER SET GENDER = '�' WHERE TEACHER='����'
SELECT * FROM TR_AUDIT;


-- 6. ������� ��� ������� TEACHER ��� AFTER-�������� � �������: TR_TEACHER_ DEL1, TR_TEACHER_DEL2 � TR_TEA-CHER_ DEL3. 
-- �������� ������ ����������� �� ������� DELETE � ����������� ��������������� ������ � ������� TR_AUDIT.  �������� ������ ��������� ������� TEACHER. 
-- ����������� ���������� ��������� ��� ������� TEACHER, ����������� �� ������� DELETE ��������� �������: 
-- ������ ������ ����������� ������� � ������ TR_TEACHER_DEL3, ��������� � ������� TR_TEACHER_DEL2. 
-- ����������: ������������ ��������� ������������� SYS.TRIGGERS � SYS.TRIGGERS_ EVENTS, � ����� ��������� ��������� SP_SETTRIGGERORDERS. 

CREATE TRIGGER TR_TEACHER_DEL1 ON TEACHER AFTER DELETE  
AS
print 'TR_TEACHER_DEL1';
DECLARE @teacher varchar(20), @nme varchar(100), @gender varchar(1), @pulp varchar(100), @res varchar(300)
SET @teacher = (SELECT TEACHER FROM deleted);
SET @nme = (SELECT TEACHER_NAME FROM deleted);
SET @gender = (SELECT GENDER FROM deleted);
SET @pulp = (SELECT PULPIT FROM deleted);
set @res = @teacher + ' ' + @nme + ' '+ @gender + ' ' + @pulp;
insert into TR_AUDIT(STMT,TRANAME,CC) 
				values('DEL','TR_TEACHER_DEL', @res);
 return;  


create trigger TR_TEACHER_DEL2 on TEACHER after DELETE  
AS
print 'TR_TEACHER_DEL2';
DECLARE @teacher varchar(20), @nme varchar(100), @gender varchar(1), @pulp varchar(100), @res varchar(300)
SET @teacher = (SELECT TEACHER FROM deleted);
SET @nme = (SELECT TEACHER_NAME FROM deleted);
SET @gender = (SELECT GENDER FROM deleted);
SET @pulp = (SELECT PULPIT FROM deleted);
set @res = @teacher + ' ' + @nme + ' '+ @gender + ' ' + @pulp;
insert into TR_AUDIT(STMT,TRANAME,CC) 
				values('DEL','TR_TEACHER_DEL', @res);

 return;  

  
create trigger TR_TEACHER_DEL3 on TEACHER after DELETE 
AS
print 'TR_TEACHER_DEL3';
DECLARE @teacher varchar(20), @nme varchar(100), @gender varchar(1), @pulp varchar(100), @res varchar(300)
SET @teacher = (SELECT TEACHER FROM deleted);
SET @nme = (SELECT TEACHER_NAME FROM deleted);
SET @gender = (SELECT GENDER FROM deleted);
SET @pulp = (SELECT PULPIT FROM deleted);
set @res = @teacher + ' ' + @nme + ' '+ @gender + ' ' + @pulp;
insert into TR_AUDIT(STMT,TRANAME,CC) 
				values('DEL','TR_TEACHER_DEL', @res);
 return;  
 
SELECT t.name, e.type_desc
	FROM sys.triggers t join sys.trigger_events e
		ON t.object_id=e.object_id
		WHERE OBJECT_NAME(t.parent_id)='TEACHER' and e.type_desc='DELETE'

EXEC sp_settriggerorder @triggername='TR_TEACHER_DEL3',
		@order = 'First', @stmttype='DELETE'
EXEC sp_settriggerorder @triggername='TR_TEACHER_DEL2',
		@order = 'Last', @stmttype='DELETE'


SELECT t.name, e.type_desc
	FROM sys.triggers t join sys.trigger_events e 
		ON t.object_id=e.object_id
		WHERE OBJECT_NAME(t.parent_id)='TEACHER' and e.type_desc='DELETE'

-- 7. ����������� ��������, ��������������� �� ������� ���� ������ X_UNIVER �����������: 
-- AFTER-������� �������� ������ ����������, � ������ �������� ����������� ��������, ���������������� �������.

CREATE TRIGGER TEACH_TRAN ON TEACHER AFTER INSERT, DELETE, UPDATE
AS
DECLARE @c int = (select COUNT(TEACHER) from TEACHER);
		if(@c > 10)
			begin
				raiserror('�������� �� ����� ���� ������ 10', 10, 1);
				rollback;
			end;
		return;

-- 8. ��� ������� FACULTY ������� INSTEAD OF-�������, ����������� �������� ����� � �������. 
-- ����������� ��������, ������� ������������� �� ������� ���� ������ X_UNIVER, ��� �������� ����������� ����������� ������e��, 
-- ���� ���� INSTEAD OF-�������.
-- � ������� ��������� DROP ������� ��� DML-��������, ��������� � ���� ������������ ������.

CREATE TRIGGER Tov_INSTEAD_OF ON FACULTY INSTEAD OF DELETE 
AS 
	raiserror(N'�������� ���������',10,1);
	return;

DELETE FROM FACULTY WHERE FACULTY='���';

-- 9. ������� DDL-�������, ����������� �� ��� DDL-������� � �� UNIVER. ������� ������ ��������� ��������� ����� ������� � ������� ������������. 
-- ���� ���������� ������� ������ ������������ ����������, ������� ��������: ��� �������, ��� � ��� �������, � ����� ������������� �����, 
-- � ������ ���������� ���������� ���������. 
-- ����������� ��������, ��������������� ������ ��������. 

CREATE TRIGGER DDL_UNIVER ON DATABASE FOR DDL_DATABASE_LEVEL_EVENTS
AS
  DECLARE @t varchar(50) =  EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)');
  DECLARE @t1 varchar(50) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(50)');
  DECLARE @t2 varchar(50) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(50)'); 
if @t='DROP_TABLE' or @t='CREATE_TABLE'
	begin
		print '��� �������: ' + @t;
		print '��� ������: ' + @t1;
		print '��� �������: ' + @t2;
		 raiserror(N'�������� �� �������� � �������� ������ ���������', 16,1);
		 rollback;
	end;

create TABLE Persons (
    PersonID int,
    LastName varchar(255),
    FirstName varchar(255),
    Address varchar(255),
    City varchar(255)
);

DROP TABLE Persons