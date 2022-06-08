-- 1. Создать процедуру для обновления данных о покупателе. Обработать ошибки
drop procedure CUSTOMER_UPDATE;
create procedure CUSTOMER_UPDATE @a int, @b varchar(20), @c int, @d decimal(9,2) AS
BEGIN TRY
 IF (@b!='') UPDATE CUSTOMERS SET COMPANY = @b WHERE CUST_NUM = @a;
 IF (@c!=0) UPDATE CUSTOMERS  SET CUST_REP = @c WHERE CUST_NUM = @a;
 IF (@d!=0) UPDATE CUSTOMERS  SET CREDIT_LIMIT = @d WHERE CUST_NUM = @a;
 return 1
 END TRY
 BEGIN CATCH
	print 'Номер ошибки: ' + cast(error_number() as varchar(6));
	print 'Сообщение: ' + error_message();
	print 'Уровень: ' + cast(error_severity() as varchar(6));
	print 'Метка: ' + cast(error_state() as varchar(8));
	print 'Номер строки: ' + cast(error_line() as varchar(8));
if error_procedure() is not null   
print 'Имя процедуры: ' + error_procedure();
return -1;
 END CATCH;

DECLARE @rc int;  
EXEC @rc = CUSTOMER_UPDATE @a = 2101, @b = NULL, @C = NULL, @d = NULL
print 'Код ошибки: ' + cast(@rc as varchar(3));

-- 1.2. Создать функцию для вычисления итоговой суммы заказов для предприятия. Параметр - код препдприятия. В случае ошибки возвращает -1
drop function sumOffice
create function sumOffice(@office int) returns int AS
BEGIN
DECLARE @rc int = (
	SELECT sum(ORDERS.AMOUNT)[Sum] FROM ORDERS 
						INNER JOIN SALESREPS
								ON ORDERS.REP = SALESREPS.EMPL_NUM 
								AND SALESREPS.EMPL_NUM IN (SELECT SALESREPS.EMPL_NUM FROM SALESREPS 
															INNER JOIN OFFICES ON SALESREPS.REP_OFFICE  = OFFICES.OFFICE and OFFICES.OFFICE LIKE @office))
	RETURN 1;
END
DECLARE @f int = dbo.sumOffice(11);

-- 1.3 Создать процедуру для выбора N сотрудников с самой давней датой найма, отсортированных по убыванию даты найма. Параметр N. Обработать ошибки.

CREATE PROCEDURE chooseEmpl @amountOfEmpls int AS 
BEGIN TRY
	SELECT TOP(@amountOfEmpls) SALESREPS.NAME FROM SALESREPS
	ORDER BY SALESREPS.HIRE_DATE desc
	return 1
END TRY
BEGIN CATCH
	print 'Номер ошибки: ' + cast(error_number() as varchar(6));
	print 'Сообщение: ' + error_message();
	print 'Уровень: ' + cast(error_severity() as varchar(6));
	print 'Метка: ' + cast(error_state() as varchar(8));
	print 'Номер строки: ' + cast(error_line() as varchar(8));
if error_procedure() is not null   
print 'Имя процедуры: ' + error_procedure();
return -1;
END CATCH;

DECLARE @itog int
EXEC @itog = chooseEmpl @amountOfEmpls = 3;


-- 1.4 Создать функцию, которая подсчитывает количество товаров для определённого производителя. Параметр - часть наименования производителя. В сл

CREATE FUNCTION countItems(@nameofseller varchar(20)) returns table
AS RETURN
SELECT count(ORDERS.PRODUCT)[Количество товаров], CUSTOMERS.COMPANY[Производитель]
	FROM ORDERS JOIN CUSTOMERS on ORDERS.CUST = CUSTOMERS.CUST_NUM 
					AND CUSTOMERS.CUST_NUM IN (SELECT CUSTOMERS.CUST_NUM FROM CUSTOMERS WHERE CUSTOMERS.COMPANY LIKE @nameofseller)
	GROUP BY CUSTOMERS.COMPANY

SELECT * FROM dbo.countItems('Jones Mfg.');
