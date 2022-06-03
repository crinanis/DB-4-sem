---uncommitted
BEGIN TRAN
DELETE FROM AUDITORIUM WHERE AUDITORIUM='423-1'
select count(*) from AUDITORIUM
Rollback tran

---committed
BEGIN TRAN
DELETE FROM AUDITORIUM WHERE AUDITORIUM='423-1'
select count(*) from AUDITORIUM
Rollback tran

DELETE FROM AUDITORIUM WHERE AUDITORIUM='423-1'
select count(*) from AUDITORIUM
commit tran

--Repeatable read
Begin tran
DELETE FROM AUDITORIUM WHERE AUDITORIUM='423-1'
commit tran
insert into AUDITORIUM Values('202', 'À ',60,'202-1');
select count(*) from AUDITORIUM
commit tran

begin tran 
insert into AUDITORIUM Values('202', 'À ',60,'202-1');
commit tran


