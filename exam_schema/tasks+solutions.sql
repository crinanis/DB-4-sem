use exam_schema;

-- Ќайти товары,  которые заказывали сотрудники из офисов ¬осточного региона.

SELECT p.PRODUCT_ID, p.DESCRIPTION, s.NAME, ofi.REGION
FROM            PRODUCTS p
						 INNER JOIN ORDERS o ON p.MFR_ID = o.MFR AND p.PRODUCT_ID = o.PRODUCT 
						 INNER JOIN CUSTOMERS c ON o.CUST = c.CUST_NUM 
						 INNER JOIN SALESREPS s ON o.REP = s.EMPL_NUM AND c.CUST_REP = s.EMPL_NUM 
						 INNER JOIN (SELECT*FROM OFFICES WHERE REGION = 'Eastern') AS ofi ON s.EMPL_NUM = ofi.MGR AND s.REP_OFFICE = ofi.OFFICE
GROUP BY p.PRODUCT_ID, p.DESCRIPTION, s.NAME, ofi.REGION


-- ѕодсчитать среднюю цену товара дл€ каждого сотрудника и найти тех, у кого средн€€ цена товара больше 600.

SELECT p.PRODUCT_ID, p.DESCRIPTION, avg(p.PRICE) as AVG_PRICE, s.NAME
FROM			PRODUCTS p
						INNER JOIN ORDERS o ON p.MFR_ID = o.MFR AND p.PRODUCT_ID = o.PRODUCT
						INNER JOIN CUSTOMERS c ON o.CUST = c.CUST_NUM
						INNER JOIN SALESREPS s on o.REP = s.EMPL_NUM AND c.CUST_REP = s.EMPL_NUM
						INNER JOIN OFFICES ofi ON s.EMPL_NUM = ofi.MGR
GROUP BY p.PRODUCT_ID, p.DESCRIPTION, p.PRICE, s.NAME
HAVING avg(p.PRICE)>600



-- Ќайти товары, которые не заказывали сотрудники из офисов ¬осточного региона

SELECT DISTINCT p.PRODUCT_ID 
FROM			PRODUCTS p
							except
							SELECT DISTINCT (ord.PRODUCT) PRODUCT FROM SALESREPS r
							JOIN OFFICES ofs on r.REP_OFFICE = ofs.OFFICE and ofs.REGION = 'Eastern'
							JOIN ORDERS ord ON r.EMPL_NUM = ord.REP


-- --найти товары, которые не заказывали сотрудники из офисов ¬осточного региона
select p.PRODUCT_ID
From PRODUCTS as p
Where not exists(select* from ORDERS as o
Where o.PRODUCT=p.PRODUCT_ID
and o.PRODUCT in (select o1.PRODUCT
from ORDERS o1 inner join SALESREPS s
on o1.REP=s.EMPL_NUM and 
s.REP_OFFICE IN (select s2.REP_OFFICE
From SALESREPS s2 inner join OFFICES o2
on s2.REP_OFFICE=o2.OFFICE and o2.REGION Like 'Eastern')))

-- Ќайти офисы, в которых не было заказов в период с 01.01.2007 по 01.01.2008

select d.OFFICE from OFFICES as d
where OFFICE not in
(select distinct OFFICE from SALESREPS r
join OFFICES ofs on r.REP_OFFICE = ofs.OFFICE
join ORDERS ord on ord.REP = r.EMPL_NUM and ORDER_DATE between '01-01-2007' and '01-01-2008')

-- Ќайти самый дорогой товар, проданный каждым сотрудником и отсортировать по значению цены товара

SELECT PRODUCTS.PRODUCT_ID, PRODUCTS.DESCRIPTION, max(PRODUCTS.PRICE) as MAX_PRICE, SALESREPS.NAME
FROM			PRODUCTS
						INNER JOIN ORDERS ON PRODUCTS.MFR_ID = ORDERS.MFR AND PRODUCTS.PRODUCT_ID=ORDERS.PRODUCT
						INNER JOIN CUSTOMERS ON ORDERS.CUST = CUSTOMERS.CUST_NUM
						INNER JOIN SALESREPS on ORDERS.REP = SALESREPS.EMPL_NUM AND CUSTOMERS.CUST_REP = SALESREPS.EMPL_NUM
						INNER JOIN OFFICES ON SALESREPS.EMPL_NUM = OFFICES.MGR
GROUP BY PRODUCTS.PRODUCT_ID, PRODUCTS.DESCRIPTION, PRODUCTS.PRICE, SALESREPS.NAME
ORDER BY PRODUCTS.PRICE desc

-- ќфисы в которых были заказы с 01.01.2007 до 01.01.2008

select distinct OFFICE from SALESREPS r
join OFFICES ofs on r.REP_OFFICE = ofs.OFFICE
join ORDERS ord on ord.REP = r.EMPL_NUM  and ORDER_DATE between '01-01-2007' and '01-01-2008'

-- ѕодсчитать кол-во товаров, заказанных сотрудниками каждого офиса, и отсортировать по убыванию суммы всех заказов
select count(*)  ол_во, sum(ord.AMOUNT) [ќбща€ сумма], offi.OFFICE [ќфис]
from ORDERS ord
inner join SALESREPS sales
on sales.EMPL_NUM = ord.REP
inner join OFFICES offi
on offi.MGR = sales.MANAGER
where ord.REP in (select EMPL_NUM from SALESREPS s inner join OFFICES offi on offi.MGR = s.MANAGER)
group by offi.OFFICE
order by sum(ord.AMOUNT) desc

-- ѕодсчитать количество товаров , заказанных сотрудниками каждого офиса и отсортировать по убыванию суммарного значени€ всех заказов
Select s.rep_office, count(*) as amount_of_goods from ORDERS o
inner join salesreps s on s.empl_num = o.rep
group by s.rep_office
order by amount_of_goods desc;

-- Ќайти 3 товара, которые заказывали меньше всего
select top(3) QTY, PRODUCT
From ORDERS as a
order by QTY;

-- 
select top(3)  PRODUCTS.PRODUCT_ID, COALESCE(sum(QTY),0)[ оличество]
From ORDERS as a right join PRODUCTS on a.PRODUCT = PRODUCTS.PRODUCT_ID
group by PRODUCTS.PRODUCT_ID
order by sum(a.QTY) asc;

-- Ќайти 2 сотрудников , которые выполнили больше всех заказов в организаци€х с кредитным лимитом меньше 30000
select top(2) t.NAME,t.[кол-во заказов] from(
select rep.NAME,Count(*)[кол-во заказов]
from SALESREPS rep
join ORDERS ord on ord.REP = rep.EMPL_NUM
join CUSTOMERS cust on ord.CUST=cust.CUST_NUM and cust.CREDIT_LIMIT < 30000
group by rep.NAME
) t
order by [кол-во заказов] desc

-- Ќайти среднюю цену заказа дл€ каждого офиса
Select avg(o.Amount) as Amount, COUNT(*) as Office
From OFFICES ofs inner join ORDERS o
on ofs.MGR = o.REP
group by o.Amount
order by Amount desc;

----------------------------------------------
SELECT rep.EMPL_NUM, cast(max(ord.AMOUNT/ord.QTY) as int) [price], ord.PRODUCT FROM SALESREPS rep
JOIN ORDERS ord ON ord.REP = rep.EMPL_NUM

GROUP BY rep.EMPL_NUM, ord.PRODUCT
ORDER by [price] desc


SELECT distinct s.EMPL_NUM, cast(max(o.AMOUNT/o.QTY) as int) [price], o.PRODUCT FROM PRODUCTS p
INNER JOIN ORDERS o ON p.MFR_ID = o.MFR AND p.PRODUCT_ID = o.PRODUCT
						INNER JOIN CUSTOMERS c ON o.CUST = c.CUST_NUM
						INNER JOIN SALESREPS s on o.REP = s.EMPL_NUM AND c.CUST_REP = s.EMPL_NUM
						INNER JOIN OFFICES ofi ON s.EMPL_NUM = ofi.MGR
GROUP BY s.EMPL_NUM, o.PRODUCT
ORDER by [price] desc

-- Ќайти сотрудников, у которых есть заказ стоимостью выше 2000, и отсортировать по убыванию стоимости заказа
select rep.NAME,max(ord.AMOUNT)[стоимость] from ORDERS ord
join SALESREPS rep on rep.EMPL_NUM = ord.REP
where ord.AMOUNT>2000
group by rep.NAME
order by [стоимость] desc

-- ѕодсчитать количество проданных товаров дл€ каждого сотрудника и найти тех, кто продал больше 10 штук товаров
select r.NAME,Sum(o.QTY) as amount from SALESREPS r
join ORDERS o on r.EMPL_NUM = o.REP
group by r.NAME
having sum(o.QTY)>10

-- Ќайти среднюю цену заказа дл€ каждого покупател€
select CUSTOMERS.COMPANY, AVG(ORDERS.AMOUNT)
from ORDERS join CUSTOMERS
on ORDERS.CUST = CUSTOMERS.CUST_NUM
group by ORDERS.CUST, CUSTOMERS.COMPANY

-- Ќайти сотрудников, у которых нет заказов
select sls.NAME
from SALESREPS sls
where not exists(
select ord.REP
from ORDERS ord
where sls.EMPL_NUM = ord.REP
)





