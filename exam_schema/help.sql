--������� 1
--1.	������� ��������� ��������� � �������:
--1.1.	������� ��������� ��� ���������� ����������. ���������� ������.
--1.2.	������� ������� ��� ���������� ������� ���� ������ ��� ����������. �������� � ��� ����������. � ������ ������ ������� ���������� -1
--1.3.	������� ��������� ��� ������ N ����� ������� �����������. �������� � N. ���������� ������.
--1.4.	������� �������, ������� ������������ ���������� �������, ������� ��������� ��������� �� ������-���� �������. �������� � ����� ������������ �������. � ������ ������ ������� ���������� -1.
--2.	������������������ �������� �������� � �������.

--1
--������� ��������� ��� ���������� ����������. ���������� ������.
create procedure	SALESREPS_INSERT
@a int, @b varchar(15), @c int,@d int,@e varchar(10),@f date,@g int, @h decimal(9,2), @i decimal(9,2)
as begin
try
insert into SALESREPS
values (@a,@b,@c,@d,@e,@f,@g,@h,@i)
return 1
end try
begin catch
print '����� ������:'+cast(error_number() as varchar(6));
print '����� ������: ' + cast(error_number() as varchar(6));
print '���������: ' + error_message();
print '�������: ' + cast(error_severity() as varchar(6));
print '�����: ' + cast(error_state() as varchar(8));
print '����� ������: ' + cast(error_line() as varchar(8));
if error_procedure() is not null   
print '��� ���������: ' + error_procedure();
return -1;
end catch;

DECLARE @rc int;  
EXEC @rc = SALESREPS_INSERT @a = '111', @b = 'Eugene Nikolaeva', @c = 19, @d = 11,@e='Sales Rep',@f='2008-01-13',@g=101,@h=300000.00,@i=392725.00; 
print '��� ������: ' + cast(@rc as varchar(3));
go

--1.2.	������� ������� ��� ���������� ������� ���� ������ ��� ����������. 
--�������� � ��� ����������. � ������ ������ ������� ���������� -1
create function Avgamount(@code int) returns int
as begin 
declare @rc int =(
SELECT avg(ORDERS.AMOUNT)[������� ���������]
from SALESREPS
inner join ORDERS ON ORDERS.REP = SALESREPS.EMPL_NUM where SALESREPS.EMPL_NUM=@code)
return @rc;
end
go

declare @f int= dbo.Avgamount(101);
print cast(@f as varchar(4))
--1.3.	������� ��������� ��� ������ N ����� ������� �����������. �������� � N. ���������� ������.
--�������� ����� ���������� ������ ��-�������
create procedure young_salesreps  @a int
as 
begin try
select top(@a) NAME,AGE
From SALESREPS
order by AGE;
end try
begin catch
print '����� ������:'+cast(error_number() as varchar(6));
print '����� ������: ' + cast(error_number() as varchar(6));
print '���������: ' + error_message();
print '�������: ' + cast(error_severity() as varchar(6));
print '�����: ' + cast(error_state() as varchar(8));
print '����� ������: ' + cast(error_line() as varchar(8));
if error_procedure() is not null   
print '��� ���������: ' + error_procedure();
return -1;
end catch;

Declare @k int = 0;
EXEC @k = young_salesreps @a=4; 

--1.4.	������� �������, ������� ������������ ���������� �������, 
--������� ��������� ��������� �� ������-���� �������. �������� � ����� ������������ �������. 
--� ������ ������ ������� ���������� -1.

create function countamount(@region varchar(20)) returns table
as return
select count(ORDERS.PRODUCT)[���������� ������� � ���������], SALESREPS.MANAGER 
from ORDERS inner join SALESREPS
on ORDERS.REP=SALESREPS.MANAGER and
SALESREPS.MANAGER IN (select SALESREPS.MANAGER
From SALESREPS inner join OFFICES
on SALESREPS.REP_OFFICE=OFFICES.OFFICE and OFFICES.REGION Like @region)
GROUP BY SALESREPS.MANAGER

select *from dbo.countamount('Eastern')

--������� 2
--1.	������� ��������� ��������� � �������:
--1.1.	������� ��������� ��� ���������� �����. ���������� ������.
--1.2.	������� ������� ��� ���������� ������ �������� ������ ��� �����������. �������� � ����� ������������ �����������. � ������ ������ ������� ���������� -1.
--1.3.	������� ��������� ��� ������ �������, ����� ������� ������ ������������� �������� N. �������� � N. ���������� ������.
--1.4.	������� �������, ������� ������������ ���������� �������, ����������� ����� ������������ ����. �������� � ����. � ������ ������ ������� ���������� -1
--2.	������������������ �������� �������� � �������.


--1.1.	������� ��������� ��� ���������� �����. ���������� ������.
create procedure	OFFICES_INSERT
@a int, @b varchar(15),@f varchar(15), @c int,@d decimal(9,2),@e decimal(9,2)
as begin
try
insert into OFFICES
values (@a,@b,@f,@c,@d,@e)
return 1
end try
begin catch
print '����� ������:'+cast(error_number() as varchar(6));
print '����� ������: ' + cast(error_number() as varchar(6));
print '���������: ' + error_message();
print '�������: ' + cast(error_severity() as varchar(6));
print '�����: ' + cast(error_state() as varchar(8));
print '����� ������: ' + cast(error_line() as varchar(8));
if error_procedure() is not null   
print '��� ���������: ' + error_procedure();
return -1;
end catch;

DECLARE @rc int;  
EXEC @rc = OFFICES_INSERT @a = '23', @b = 'New York', @f = 'Eastern', @c = 108,@d=725000.00,@e=725000.00;
print '��� ������: ' + cast(@rc as varchar(3));
go

--1.2.	������� ������� ��� ���������� ������ �������� ������ ��� �����������. 
--�������� � ����� ������������ �����������. � ������ ������ ������� ���������� -1
create function maxAmount(@office int) returns int
as begin 
declare @rc2 int =(
SELECT max(ORDERS.AMOUNT)[�������� �� �����]
FROM ORDERS
INNER JOIN SALESREPS on ORDERS.REP = SALESREPS.EMPL_NUM 
INNER JOIN OFFICES ON SALESREPS.EMPL_NUM = OFFICES.MGR where OFFICES.OFFICE=@office)
return @rc2;
end
go

declare @f2 int= dbo.maxAmount(22);
print @f2 
--1.3.	������� ��������� ��� ������ �������, ����� ������� ������ ������������� �������� N. 
--�������� � N. ���������� ������.
create procedure Findorder(@i int)
as 
begin try
	select  ORDERS.ORDER_NUM, ORDERS.AMOUNT
	from ORDERS  Where AMOUNT>@i
end try
begin catch
print '����� ������:'+cast(error_number() as varchar(6));
print '����� ������: ' + cast(error_number() as varchar(6));
print '���������: ' + error_message();
print '�������: ' + cast(error_severity() as varchar(6));
print '�����: ' + cast(error_state() as varchar(8));
print '����� ������: ' + cast(error_line() as varchar(8));
if error_procedure() is not null   
print '��� ���������: ' + error_procedure();
return -1;
end catch;

Declare @k int = 0;
EXEC @k = Findorder @i=1000; 

--1.4.	������� �������, ������� ������������ ���������� �������, ����������� ����� ������������ ����. �������� � ����. � ������ ������ ������� ���������� -1



--������� 3
--1.	������� ��������� ��������� � �������:
--1.1.	������� ��������� ��� ���������� ������. ���������� ������.
create procedure	PRODUCT_INSERT
@a char(3), @b char(3), @c varchar(30),@d money,@e int
as begin
try
insert into PRODUCTS
values (@a,@b,@c,@d,@e)
return 1
end try
begin catch
print '����� ������:'+cast(error_number() as varchar(6));
print '����� ������: ' + cast(error_number() as varchar(6));
print '���������: ' + error_message();
print '�������: ' + cast(error_severity() as varchar(6));
print '�����: ' + cast(error_state() as varchar(8));
print '����� ������: ' + cast(error_line() as varchar(8));
if error_procedure() is not null   
print '��� ���������: ' + error_procedure();
return -1;
end catch;

DECLARE @rc int;  
EXEC @rc = PRODUCT_INSERT @a = 'ACI', @b = '410', @c = 'RetainerDDS', @d = 1111,@e=210; 
print '��� ������: ' + cast(@rc as varchar(3));
go



--1.2.	������� ������� ��� ���������� ���������� ������� ��� �����������. �������� � ����� ������������ �����������. � ������ ������ ������� ���������� -1.

create function countOFFICEamount(@office int) returns table
as return
select count(ORDERS.PRODUCT)[���������� ������� � ���������]
from ORDERS inner join SALESREPS
on ORDERS.REP=SALESREPS.EMPL_NUM and
SALESREPS.EMPL_NUM IN (select SALESREPS.EMPL_NUM
From SALESREPS inner join OFFICES
on SALESREPS.REP_OFFICE=OFFICES.OFFICE and OFFICES.OFFICE Like @office)


select *from dbo.countOFFICEamount(11)

--1.3.	������� ��������� ��� ������ �������, � ������� ���������� ����������� ������ ������ N, ��������������� �� ��������� �� ��������. �������� � N. ���������� ������.
--1.4.	������� �������, ������� ������������ ���������� �����������, ����������� ������������� ���������. �������� � ��� ���������. � ������ ������ ������� ���������� -1.
--2.	������������������ �������� �������� � �������.

--������� 4
--1.	������� ��������� ��������� � �������:
--1.1.	������� ��������� ��� ���������� ����������. ���������� ������.

create procedure	CUSTOMERS_INSERT
@a int, @b varchar(20), @c int,@d decimal(9,2)
as begin
try
insert into CUSTOMERS
values (@a,@b,@c,@d)
return 1
end try
begin catch
print '����� ������:'+cast(error_number() as varchar(6));
print '����� ������: ' + cast(error_number() as varchar(6));
print '���������: ' + error_message();
print '�������: ' + cast(error_severity() as varchar(6));
print '�����: ' + cast(error_state() as varchar(8));
print '����� ������: ' + cast(error_line() as varchar(8));
if error_procedure() is not null   
print '��� ���������: ' + error_procedure();
return -1;
end catch;

DECLARE @rc int;  
EXEC @rc = CUSTOMERS_INSERT @a = 2125, @b = 'AliMake', @c = 109, @d = 60000 
print '��� ������: ' + cast(@rc as varchar(3));
go

--1.2.	������� ������� ��� ���������� ���������� ������� ��� ����������� �� ������������ ������. ��������� � ��� �����������, ������ �������, ����� �������. � ������ ������ ������� ���������� -1.
create function countOFFICEamount(@office int, @firstdate date,@seconddate date) returns table
as return
select count(ORDERS.PRODUCT)[���������� ������� � ���������]
from ORDERS inner join SALESREPS
on ORDERS.REP=SALESREPS.EMPL_NUM and
SALESREPS.EMPL_NUM IN (select SALESREPS.EMPL_NUM
From SALESREPS inner join OFFICES
on SALESREPS.REP_OFFICE=OFFICES.OFFICE and OFFICES.OFFICE Like 11) and ORDER_DATE between @firstdate and @seconddate


select *from dbo.countOFFICEamount(11, '2007-12-17','2008-01-11')

--1.3.	������� ��������� ��� ������ N ����������� � ����� ������� ��������� �������, ��������������� �� �������� �� ����� ������. �������� � N. ���������� ������.
--1.4.	������� �������, ������� ������������ ���������� �����������, ����������� ������������� ���������. �������� � ��� ���������. � ������ ������ ������� ���������� -1.
--2.	������������������ �������� �������� � �������.
--������� 5
--1.	������� ��������� ��������� � �������:
--1.1.	������� ��������� ��� ���������� ������ � ����������. ���������� ������.
create procedure	SALEREPS_UPDATE
@a int, @b varchar(20),@c int,@d int,@j varchar(10), @e date, @f int,@g decimal(9,2),@h decimal(9,2)
as begin
try
 if(@b!='')
 update SALESREPS set NAME= @b where EMPL_NUM=@a;
  if(@c!=0)
 update SALESREPS set AGE= @C where EMPL_NUM=@a;
  if(@d!=0)
 update SALESREPS set REP_OFFICE= @d where EMPL_NUM=@a;
  if(@j!='')
 update SALESREPS set TITLE= @b where EMPL_NUM=@a;
  if(@e!='')
 update SALESREPS set HIRE_DATE= @e where EMPL_NUM=@a;
   if(@f!=0)
 update SALESREPS set MANAGER= @f where EMPL_NUM=@a;
   if(@g!=0)
 update SALESREPS set QUOTA= @g where EMPL_NUM=@a;
  if(@h!=0)
 update SALESREPS set SALES= @h where EMPL_NUM=@a;
return 1
end try
begin catch
print '����� ������:'+cast(error_number() as varchar(6));
print '����� ������: ' + cast(error_number() as varchar(6));
print '���������: ' + error_message();
print '�������: ' + cast(error_severity() as varchar(6));
print '�����: ' + cast(error_state() as varchar(8));
print '����� ������: ' + cast(error_line() as varchar(8));
if error_procedure() is not null   
print '��� ���������: ' + error_procedure();
return -1;
end catch;

DECLARE @rc int;  
EXEC @rc = SALEREPS_UPDATE @a = 101, @b =NULL, @C=NULL,@d=NULL,@j=NULL,@e=NULL,@f=NULL,@g=null,@h=19
print '��� ������: ' + cast(@rc as varchar(3));
go


--1.2.	������� ������� ��� ���������� �������� ����� ������� ��� �����������. �������� � ��� �����������. � ������ ������ ������� ���������� -1.

create function sumAmountOFFICE(@office int) returns table
as return
select sum(ORDERS.AMOUNT)[�����]
from ORDERS inner join SALESREPS
on ORDERS.REP=SALESREPS.EMPL_NUM and
SALESREPS.EMPL_NUM IN (select SALESREPS.EMPL_NUM
From SALESREPS inner join OFFICES
on SALESREPS.REP_OFFICE=OFFICES.OFFICE and OFFICES.OFFICE Like @office) 

select *from dbo.sumAmountOFFICE(11)


--1.3.	������� ��������� ��� ������ N ����������� � ����� ������ ����� �����, ��������������� �� �������� ���� �����. �������� � N. ���������� ������.
--1.4.	������� �������, ������� ������������ ���������� ������� ��� ������������� �������������. �������� � ����� ������������ �������������. � ������ ������ ������� ���������� -1.
--2.	������������������ �������� �������� � �������.

--������� 6
--1.	������� ��������� ��������� � �������:
--1.1.	������� ��������� ��� ���������� ������ � ����������. ���������� ������.

create procedure	CUSTOMERS_UPDATE
@a int, @b varchar(20),@c int,@h decimal(9,2)
as begin
try
 if(@b!='')
 update CUSTOMERS set COMPANY= @b where CUST_NUM=@a;
  if(@c!=0)
 update CUSTOMERS set CUST_REP= @C where CUST_NUM=@a;
  if(@h!=0)
 update CUSTOMERS set CREDIT_LIMIT= @h where CUST_NUM=@a;
return 1
end try
begin catch
print '����� ������:'+cast(error_number() as varchar(6));
print '����� ������: ' + cast(error_number() as varchar(6));
print '���������: ' + error_message();
print '�������: ' + cast(error_severity() as varchar(6));
print '�����: ' + cast(error_state() as varchar(8));
print '����� ������: ' + cast(error_line() as varchar(8));
if error_procedure() is not null   
print '��� ���������: ' + error_procedure();
return -1;
end catch;

DECLARE @rc int;  
EXEC @rc = CUSTOMERS_UPDATE @a = 2125, @b ='AliMake', @C=107,@h=15
print '��� ������: ' + cast(@rc as varchar(3));
go



--1.2.	������� ������� ��� ���������� �������� ����� ������� ��� �����. �������� � ��� �����. � ������ ������ ������� ���������� -1.
create function sumAmountOFFICE(@office int) returns table
as return
select sum(ORDERS.AMOUNT)[�����]
from ORDERS inner join SALESREPS
on ORDERS.REP=SALESREPS.EMPL_NUM and
SALESREPS.EMPL_NUM IN (select SALESREPS.EMPL_NUM
From SALESREPS inner join OFFICES
on SALESREPS.REP_OFFICE=OFFICES.OFFICE and OFFICES.OFFICE Like @office) 

select *from dbo.sumAmountOFFICE(11)


--1.3.	������� ��������� ��� ������ ����������� � �� ��������, ���������� � ������������ �����, ��������������� �� ����������� ����. �������� � �����. ���������� ������.
--1.4.	������� �������, ������� ������� ����� ������� ������ ��������������. �������� � ����� ������������ �������������. � ������ ������ ������� ���������� -1.
--2.	������������������ �������� �������� � �������.

--������� 7
--1.	������� ��������� ��������� � �������:
--1.1.	������� ��������� ��� ���������� ������ � ������. ���������� ������.
create procedure	ORDERS_UPDATE
@a int, @b date, @f int,@g decimal(9,2)
as begin
try
 if(@b!='')
 update ORDERS set ORDER_DATE= @b where ORDER_NUM=@a;
   if(@f!=0)
 update ORDERS set QTY= @f where ORDER_NUM=@a;
   if(@g!=0)
 update ORDERS set AMOUNT= @g where ORDER_NUM=@a;
return 1
end try
begin catch
print '����� ������:'+cast(error_number() as varchar(6));
print '����� ������: ' + cast(error_number() as varchar(6));
print '���������: ' + error_message();
print '�������: ' + cast(error_severity() as varchar(6));
print '�����: ' + cast(error_state() as varchar(8));
print '����� ������: ' + cast(error_line() as varchar(8));
if error_procedure() is not null   
print '��� ���������: ' + error_procedure();
return -1;
end catch;

DECLARE @rc int;  
EXEC @rc = ORDERS_UPDATE @a = 113069, @b ='2007-11-04',@f=14,@g=15
print '��� ������: ' + cast(@rc as varchar(3));
go




--1.2.	������� ������� ���������� �����������, ������� �� �������� �� ������ ������. � ������ ������ ������� ���������� -1.
create function CUSTOMERNAME(@amount int) returns table
as return
select DISTINCT NAME,EMPL_NUM 
from SALESREPS
inner join ORDERS on EMPL_NUM=REP and EMPL_NUM not in(select EMPL_NUM from SALESREPS
inner join ORDERS on EMPL_NUM=REP)



--1.3.	������� ������� ���������� ������ �� ������������� �������. �������� � ����� ������������ �������. � ������ ������ ������� ���������� -1.
--1.4.	������� ��������� ���������� N �������, ������� �������� ���� �����. �������� � N. ���������� ������.
--2.	������������������ � ��������� ����� �������� �������� � �������.
.
--������� 8
--1.	������� ��������� ��������� � �������:
--1.1.	������� ��������� ��� ���������� ������ � ������. ���������� ������.

create procedure ORDER_INSERT
@a int, @b date, @c int,@d int,@e char(3),@f char(5), @g int,@h decimal(9,2)

as begin
try
insert into ORDERS
values (@a,@b,@c,@d,@e,@f,@g,@h);
return 1
end try
begin catch
print '����� ������:'+cast(error_number() as varchar(6));
print '����� ������: ' + cast(error_number() as varchar(6));
print '���������: ' + error_message();
print '�������: ' + cast(error_severity() as varchar(6));
print '�����: ' + cast(error_state() as varchar(8));
print '����� ������: ' + cast(error_line() as varchar(8));
if error_procedure() is not null   
print '��� ���������: ' + error_procedure();
return -1;
end catch;

DECLARE @rc int;  
EXEC @rc = ORDER_INSERT @a = 113070, @b = '2007-11-04', @c = 2124, @d = 109,@e='FEA',@f=112,@g=15,@h=13   
print '��� ������: ' + cast(@rc as varchar(3));
go



--1.2.	������� ������� ���������� �����������, � ������� ���� ����� ��������� ���� ������������� �������� N. �������� � N. � ������ ������ ������� ���������� -1.

create function CUSTOMERNAME(@amount int) returns table
as return
select DISTINCT NAME,EMPL_NUM
from SALESREPS
inner join ORDERS on EMPL_NUM=REP and AMOUNT>@amount

select *from dbo.CUSTOMERNAME(100)

--1.3.	������� ������� ���������� ������� ������ ������������ ���������. �������� � ���������� ���������. � ������ ������ ������� ���������� -1.
--1.4.	������� ��������� ���������� N �������, ������� �������� ���� �����. �������� � N. ���������� ������.
--2.	������������������ � ��������� ����� �������� �������� � �������.
