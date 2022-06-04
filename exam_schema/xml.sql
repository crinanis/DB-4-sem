-- ������� � 1 �������� xml, �������� ���� ��� ��������� xml
-- � ����� - ���������� ���������� �������
-- � ����� - ���������� ��������� �������
-- � ����� - ��� ����������
-- ��������� � xml ���� ����� ���������� �������� �������� �� 1 ���� ������ ��� ������

CREATE TABLE EMPLOYEES( 
	row_num int, 
	fragment xml
)

TRUNCATE TABLE EMPLOYEES;
SELECT * FROM EMPLOYEES;

DECLARE @doc nvarchar(3000);
DECLARE @region1 nvarchar(1000), @region2 nvarchar(1000), @region3 nvarchar(1000);

-- ������ ��������
SET @region1 = (SELECT T1.REGION AS '@������', 
						(
						SELECT SALESREPS.NAME AS '@���', SALESREPS.HIRE_DATE AS '@����_�����'
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


-- ������ ��������
SET @region2 = (SELECT T1.REGION AS '@������', 
						(
						SELECT SALESREPS.NAME AS '@���', DATEADD(DAY, 1, SALESREPS.HIRE_DATE) as '@����_�����'
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


-- ������ ��������
SET @region3 = (SELECT CONCAT_WS(' ', @region1, @region2))

-- ���������� � ���� ��������
SET @doc = '<employees>' + 
				'<FR1>' + @region1 + '</FR1>' + 
				'<FR2>' + @region2 + '</FR2>' +
				'<FR3>' + @region3 + '</FR3>' + 
			'</employees>';

insert into EMPLOYEES(row_num, fragment) values (1, cast(@doc as xml))

SELECT * FROM EMPLOYEES

