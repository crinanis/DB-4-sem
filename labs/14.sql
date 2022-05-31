CREATE TABLE TR_AUDIT
(
	ID int identity,	--номер
	STMT varchar(20)	--DML_оператор
		check (STMT in('INS','DEL','UPD')),
	TRANAME varchar(50),--имя триггера
	CC varchar(300)	--комментарий
)

-- 1. Разработать AFTER-триггер с именем TR_TEACHER_INS для таблицы TEACHER, реагирующий на событие INSERT. 
-- Триггер должен записывать строки вводимых данных в таблицу TR_AUDIT. В столбец СС помещаются значения столбцов вводимой строки.

CREATE TRIGGER TR_TEACHER_INS ON TEACHER AFTER INSERT
AS
DECLARE @teacher varchar(20), @nme varchar(100), @gender varchar(1), @pulp varchar(100), @res varchar(300)
print 'Операция вставки';
set @teacher = (select TEACHER from INSERTED);
set @nme = (select TEACHER_NAME from INSERTED);
set @gender = (select GENDER from INSERTED);
set @pulp = (select PULPIT from INSERTED);
set @res = @teacher + ' ' + @nme + ' '+ @gender + ' ' + @pulp;
INSERT INTO TR_AUDIT(STMT,TRANAME,CC) 
				values('INS','TR_TEACHER_INS', @res);
return;


INSERT INTO TEACHER values('ИВНВ', 'Иванов Иван Иванович', 'м', 'ИСиТ');
SELECT * FROM TR_AUDIT
	 
	 
-- 2. Создать AFTER-триггер с именем TR_TEACHER_DEL для таблицы TEACHER, реагирующий на событие DELETE. 
-- Триггер должен записывать строку данных в таблицу TR_AUDIT для каждой удаляемой строки. 
-- В столбец СС помещаются значения столбца TEACHER удаляемой строки. 

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


DELETE FROM TEACHER WHERE TEACHER = 'ИВНВ';
SELECT * FROM TR_AUDIT;


 -- 3. Создать AFTER-триггер с именем TR_TEACHER_UPD для таблицы TEACHER, реагирующий на событие UPDATE. 
 -- Триггер должен записывать строку данных в таблицу TR_AUDIT для каждой изменяемой строки. 
 -- В столбец СС помещаются значения столбцов изменяемой строки до и после изменения.

CREATE TRIGGER TR_TEACHER_UPD ON TEACHER AFTER UPDATE
AS
DECLARE @teacher varchar(20), @nme varchar(100), @gender varchar(1), @pulp varchar(100), @res varchar(300)
 print 'Операция обновления';
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

UPDATE TEACHER SET GENDER = 'ж' WHERE TEACHER='ИВНВ'
SELECT * FROM TR_AUDIT;


-- 4. Создать AFTER-триггер с именем TR_TEACHER для таблицы TEACHER, реагирующий на события INSERT, DELETE, UPDATE. 
-- Триггер должен записывать строку данных в таблицу TR_AUDIT для каждой изменяемой строки. В коде триггера определить событие,
-- активизировавшее триггер и поместить в столбец СС соответствующую событию информацию. 
-- Разработать сценарий, демонстрирующий работоспособность триггера. 

CREATE TRIGGER TR_TEACHER ON TEACHER AFTER INSERT, DELETE, UPDATE
AS
DECLARE @teacher varchar(20), @nme varchar(100), @gender varchar(1), @pulp varchar(100), @res varchar(300)

DECLARE @ins int = (select count(*) from inserted), @del int = (select count(*) from deleted);
	if @ins > 0 and @del = 0
		begin 
		print 'Событие добавление';
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
			print 'Операция удаления'
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
			  print 'Операция обновления';
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


UPDATE TEACHER SET GENDER = 'м' WHERE TEACHER='ИВНВ'
DELETE FROM TEACHER WHERE TEACHER = 'ИВНВ';
INSERT INTO TEACHER values('ИВНВ', 'Иванов Иван Иванович', 'м', 'ИСиТ');
SELECT * FROM TR_AUDIT;

-- 5. Разработать сценарий, который демон-стрирует на примере базы данных X_UNIVER, 
-- что проверка ограничения це-лостности выполняется до срабатывания AF-TER-триггера.

UPDATE TEACHER SET GENDER = 'й' WHERE TEACHER='ИВНВ'
SELECT * FROM TR_AUDIT;


-- 6. Создать для таблицы TEACHER три AFTER-триггера с именами: TR_TEACHER_ DEL1, TR_TEACHER_DEL2 и TR_TEA-CHER_ DEL3. 
-- Триггеры должны реагировать на событие DELETE и формировать соответствующие строки в таблицу TR_AUDIT.  Получить список триггеров таблицы TEACHER. 
-- Упорядочить выполнение триггеров для таблицы TEACHER, реагирующих на событие DELETE следующим образом: 
-- первым должен выполняться триггер с именем TR_TEACHER_DEL3, последним – триггер TR_TEACHER_DEL2. 
-- Примечание: использовать системные представления SYS.TRIGGERS и SYS.TRIGGERS_ EVENTS, а также системную процедуру SP_SETTRIGGERORDERS. 

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

-- 7. Разработать сценарий, демонстрирующий на примере базы данных X_UNIVER утверждение: 
-- AFTER-триггер является частью транзакции, в рамках которого выполняется оператор, активизировавший триггер.

CREATE TRIGGER TEACH_TRAN ON TEACHER AFTER INSERT, DELETE, UPDATE
AS
DECLARE @c int = (select COUNT(TEACHER) from TEACHER);
		if(@c > 10)
			begin
				raiserror('Учителей не может быть больше 10', 10, 1);
				rollback;
			end;
		return;

-- 8. Для таблицы FACULTY создать INSTEAD OF-триггер, запрещающий удаление строк в таблице. 
-- Разработать сценарий, который демонстрирует на примере базы данных X_UNIVER, что проверка ограничения целостности выполнeна, 
-- если есть INSTEAD OF-триггер.
-- С помощью оператора DROP удалить все DML-триггеры, созданные в этой лабораторной работе.

CREATE TRIGGER Tov_INSTEAD_OF ON FACULTY INSTEAD OF DELETE 
AS 
	raiserror(N'Удаление запрещено',10,1);
	return;

DELETE FROM FACULTY WHERE FACULTY='ФИТ';

-- 9. Создать DDL-триггер, реагирующий на все DDL-события в БД UNIVER. Триггер должен запрещать создавать новые таблицы и удалять существующие. 
-- Свое выполнение триггер должен сопровождать сообщением, которое содержит: тип события, имя и тип объекта, а также пояснительный текст, 
-- в случае запрещения выполнения оператора. 
-- Разработать сценарий, демонстрирующий работу триггера. 

CREATE TRIGGER DDL_UNIVER ON DATABASE FOR DDL_DATABASE_LEVEL_EVENTS
AS
  DECLARE @t varchar(50) =  EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]', 'varchar(50)');
  DECLARE @t1 varchar(50) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'varchar(50)');
  DECLARE @t2 varchar(50) = EVENTDATA().value('(/EVENT_INSTANCE/ObjectType)[1]', 'varchar(50)'); 
if @t='DROP_TABLE' or @t='CREATE_TABLE'
	begin
		print 'Тип события: ' + @t;
		print 'Имя обекта: ' + @t1;
		print 'Тип объекта: ' + @t2;
		 raiserror(N'Операции по удалению и созданию таблиц запрещены', 16,1);
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