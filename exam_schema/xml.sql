-- таблица с 1 столбцом xml, положить туда три фрагмента xml
-- в одном - сотрудники восточного региона
-- в одном - сотрудники западного региона
-- в одном - все сотрудники
-- поставить в xml дату найма сотрудника западных регионов на 1 день больше или меньше

CREATE TABLE EMPLOYEES( 
	row_num int, 
	fragment xml
)

TRUNCATE TABLE EMPLOYEES;
SELECT * FROM EMPLOYEES;

DECLARE @doc nvarchar(3000);
DECLARE @region1 nvarchar(1000), @region2 nvarchar(1000), @region3 nvarchar(1000);

-- ПЕРВЫЙ ФРАГМЕНТ
SET @region1 = (SELECT T1.REGION AS '@регион', 
						(
						SELECT SALESREPS.NAME AS '@имя', SALESREPS.HIRE_DATE AS '@дата_найма'
						FROM SALESREPS
						join OFFICES AS T3 ON T3.OFFICE = SALESREPS.REP_OFFICE
						WHERE T1.REGION = t3.REGION
						ORDER BY SALESREPS.NAME
						FOR XML PATH('REP'), TYPE
						)
		FROM OFFICES AS T1 WHERE T1.REGION='Eastern'
		GROUP BY REGION
		FOR XML PATH('REGION')
)


-- ВТОРОЙ ФРАГМЕНТ
SET @region2 = (SELECT T1.REGION AS '@регион', 
						(
						SELECT SALESREPS.NAME AS '@имя', DATEADD(DAY, 1, SALESREPS.HIRE_DATE) as '@дата_найма'
						FROM SALESREPS
						join OFFICES AS T3 ON T3.OFFICE = SALESREPS.REP_OFFICE
						WHERE T1.REGION = t3.REGION
						ORDER BY SALESREPS.NAME
						FOR XML PATH('REP'), TYPE
						)
		FROM OFFICES AS T1 WHERE T1.REGION='Western'
		GROUP BY REGION
		FOR XML PATH('REGION')
)


-- ТРЕТИЙ ФРАГМЕНТ
SET @region3 = (SELECT CONCAT_WS(' ', @region1, @region2))

-- ОБЪЕДИНЯЕМ В ОДИН ДОКУМЕНТ
SET @doc = '<employees>' + 
				'<FR1>' + @region1 + '</FR1>' + 
				'<FR2>' + @region2 + '</FR2>' +
				'<FR3>' + @region3 + '</FR3>' + 
			'</employees>';

insert into EMPLOYEES(row_num, fragment) values (1, cast(@doc as xml))

SELECT * FROM EMPLOYEES

