---uncommitted
set transaction isolation level read uncommitted 
begin tran
select count(*) from AUDITORIUM

select count(*) from AUDITORIUM
commit tran

--committed
set transaction isolation level read committed
begin tran
select count(*) from AUDITORIUM

insert into AUDITORIUM Values('202', 'À ',60,'202-1');

--Repeatable read
set transaction isolation level repeatable read
begin tran
select count(*) from AUDITORIUM
commit tran

Set transaction isolation level serializable
begin tran
select count(*) from AUDITORIUM
commit tran

set transaction isolation level snapshot
begin tran
select count(*) from AUDITORIUM