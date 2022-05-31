--------------------------------------------------------------------------------------------------------
SELECT DISTINCT p.PRODUCT_ID 
FROM			PRODUCTS p
							except
							SELECT DISTINCT (ord.PRODUCT) PRODUCT FROM SALESREPS r
							JOIN ORDERS ord ON r.EMPL_NUM = ord.REP
							JOIN OFFICES ofs on r.REP_OFFICE = ofs.OFFICE WHERE ofs.REGION = 'Eastern'
							
--0.0415998

CREATE NONCLUSTERED INDEX i1 ON PRODUCTS(PRODUCT_ID); --0,0300819
CREATE NONCLUSTERED INDEX i2 ON ORDERS(PRODUCT); -- не изменился
CREATE NONCLUSTERED INDEX i3 ON OFFICES(REGION) where REGION = 'Eastern'; -- 0.0300614
CREATE NONCLUSTERED INDEX i4 ON ORDERS(PRODUCT, REP); -- 0.028358
CREATE INDEX i5 ON SALESREPS(EMPL_NUM, REP_OFFICE); -- 0.028358
CREATE NONCLUSTERED INDEX i6 ON ORDERS(ORDER_NUM, PRODUCT, REP); -- не изменился
CREATE NONCLUSTERED INDEX i7 ON ORDERS(ORDER_NUM, ORDER_DATE, PRODUCT, REP); -- не изменился
CREATE NONCLUSTERED INDEX i8 ON ORDERS(PRODUCT, REP) INCLUDE (ORDER_NUM); --0.028358

-- ИТОГ
-- Было: 0.0415998
-- Стало: 0.028358

------------------------------------------------------------------------------------------------------
SELECT p.PRODUCT_ID, p.DESCRIPTION, s.NAME, ofi.REGION
FROM            PRODUCTS p
						 INNER JOIN ORDERS o ON p.MFR_ID = o.MFR AND p.PRODUCT_ID = o.PRODUCT 
						 INNER JOIN CUSTOMERS c ON o.CUST = c.CUST_NUM 
						 INNER JOIN SALESREPS s ON o.REP = s.EMPL_NUM AND c.CUST_REP = s.EMPL_NUM 
						 INNER JOIN (SELECT * FROM OFFICES WHERE REGION = 'Eastern') AS ofi ON s.EMPL_NUM = ofi.MGR AND s.REP_OFFICE = ofi.OFFICE
GROUP BY p.PRODUCT_ID, p.DESCRIPTION, s.NAME, ofi.REGION


-- 0,0648901

CREATE INDEX i21 ON PRODUCTS(PRODUCT_ID, DESCRIPTION); -- не изменился
CREATE INDEX i22 ON OFFICES(REGION); -- не изменился
CREATE INDEX i23 ON PRODUCTS(PRODUCT_ID) INCLUDE (DESCRIPTION); -- не изменился
CREATE INDEX i24 ON ORDERS(MFR); -- не изменился
CREATE INDEX i25 ON ORDERS(CUST) INCLUDE (MFR); --0.0520713
CREATE INDEX i26 ON OFFICES(REGION) WHERE REGION = 'Eastern'; -- не изменился
CREATE INDEX i27 ON SALESREPS(NAME, EMPL_NUM, REP_OFFICE); -- не изменился
CREATE INDEX i28 ON SALESREPS(NAME); -- не изменился
CREATE INDEX i29 ON OFFICES(MGR, OFFICE, REGION); -- 0.0376651
CREATE NONCLUSTERED INDEX i30 ON CUSTOMERS(CUST_NUM, CUST_REP); -- не изменился
CREATE NONCLUSTERED INDEX i31 ON CUSTOMERS(CUST_NUM) INCLUDE (CUST_REP) -- не изменился
CREATE INDEX i32 ON SALESREPS(NAME) INCLUDE (EMPL_NUM, REP_OFFICE); -- не изменился
CREATE NONCLUSTERED INDEX i33 ON CUSTOMERS(CUST_NUM); --не изменился
CREATE INDEX i34 ON SALESREPS(REP_OFFICE, EMPL_NUM, NAME); -- 0.037663
CREATE NONCLUSTERED INDEX i35 ON PRODUCTS(MFR_ID, PRODUCT_ID) INCLUDE(DESCRIPTION); -- не изменился
drop index i36 ON ORDERS
CREATE INDEX i36 ON ORDERS(ORDER_NUM) INCLUDE (PRODUCT, REP); -- не изменился
CREATE INDEX i37 ON CUSTOMERS(CUST_REP) INCLUDE (CUST_NUM); --0,0344638

-- ИТОГ
-- Было: 0,0648901
-- Стало: 0,0344638





-- НЕПУТЁВЫЕ ИНДЕКСЫ
-- Подсчитать кол-во товаров, заказанных сотрудниками каждого офиса, и отсортировать по убыванию суммы всех заказов
select count(*) Кол_во, sum(ord.AMOUNT) [Общая сумма], offi.OFFICE [Офис]
from ORDERS ord
inner join SALESREPS sales
on sales.EMPL_NUM = ord.REP
inner join OFFICES offi
on offi.MGR = sales.MANAGER
where ord.REP in (select EMPL_NUM from SALESREPS s inner join OFFICES offi on offi.MGR = s.MANAGER)
group by offi.OFFICE
order by sum(ord.AMOUNT) desc

-- 0.0387764
CREATE NONCLUSTERED INDEX in1 ON ORDERS(AMOUNT); -- no change
CREATE INDEX in2 ON SALESREPS(EMPL_NUM); -- no change
CREATE INDEX in3 ON OFFICES(OFFICE); -- no change
CREATE INDEX in4 ON OFFICES(OFFICE, MGR); -- no change
CREATE INDEX in5 ON OFFICES(MGR); -- 0.0403743


-- Найти среднюю цену заказа для каждого покупателя
select CUSTOMERS.COMPANY, AVG(ORDERS.AMOUNT)
from ORDERS join CUSTOMERS
on ORDERS.CUST = CUSTOMERS.CUST_NUM
group by ORDERS.CUST, CUSTOMERS.COMPANY

-- 0.011698
CREATE INDEX optimize1 on CUSTOMERS(COMPANY); -- не изменился
CREATE INDEX optimize2 ON ORDERS(CUST); -- не изменился
CREATE INDEX optimize3 ON ORDERS(AMOUNT); -- не изменился
CREATE INDEX optimize4 ON ORDERS(AMOUNT, CUST); -- не изменился
CREATE INDEX optimize5 ON CUSTOMERS(CUST_NUM); -- не изменился
CREATE INDEX optimize6 ON CUSTOMERS(CUST_NUM, COMPANY); -- 0.0116725

CREATE NONCLUSTERED INDEX iptimize7 ON ORDERS(ORDER_NUM, AMOUNT, CUST); 
CREATE NONCLUSTERED INDEX iptimize8 ON ORDERS(AMOUNT, CUST); 


------------------------------------------------------------
select offi.OFFICE [Офис] from OFFICES offi
inner join SALESREPS s on s.REP_OFFICE = offi.OFFICE
inner join ORDERS o on o.REP = s.EMPL_NUM
where o.ORDER_DATE between '2007-01-01' and '2008-01-01'
group by offi.OFFICE

--0,0239298
create index t1 on ORDERS(REP) --не меняется
create index t2 on SALESREPS(REP_OFFICE) --0,020517
create index t3 on ORDERS(ORDER_DATE) where ORDER_DATE >= '2007-01-01' and ORDER_DATE <= '2008-01-01' --0,021517
create index t4 on ORDERS(ORDER_DATE) include (REP) --0,0238703
create nonclustered index t5 on OFFICES(OFFICE) --не меняется
create nonclustered index t6 on ORDERS(REP) -- не меняется
create nonclustered index t7 on ORDERS(ORDER_NUM) --не меняетcя
create nonclustered index t8 on ORDERS(ORDER_NUM, ORDER_DATE, REP) --0,0201517

--0,0239298
--0,0201517