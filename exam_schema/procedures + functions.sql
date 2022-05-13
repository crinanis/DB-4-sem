use exam_schema;

-- ���������

-- 1. ����� �����, � ������� �� ���� ������� � ������ � 01.01.2007 �� 01.01.2008
ALTER PROCEDURE FIND_OFFICE @beg date, @end date
AS
BEGIN
		SELECT d.OFFICE FROM OFFICES as d
						WHERE OFFICE not in (SELECT DISTINCT OFFICE FROM SALESREPS r
									JOIN OFFICES ofs on r.REP_OFFICE = ofs.OFFICE
									JOIN ORDERS ord on ord.REP = r.EMPL_NUM AND ORDER_DATE BETWEEN @beg AND @end)
END;
EXEC FIND_OFFICE @beg = '01-01-2007', @end = '01-01-2008';



-- 2. ����� ����� ������� �����, ��������� ������ ����������� (�������� ��������� � ���������� � ������� �� ����������).
CREATE PROCEDURE FIND_ITEM @param int
AS
BEGIN
	SELECT rep.NAME, MAX(convert(float, (ord.AMOUNT/ord.QTY)))[����� ������� �����] FROM SALESREPS rep
						JOIN ORDERS ord ON ord.REP = rep.EMPL_NUM
						WHERE rep.AGE > @param
						GROUP BY rep.NAME
END;

EXEC FIND_ITEM @param = 30;

-- 3. ������� ��������� ��� ����� �� ������, ������� ����� ������������ �������� INSERT � ������������ ������������ ������

use UNIVER;
CREATE PROCEDURE A_INSERT @aud char(20), @tpe char(10), @cap int = 0, @nme varchar(50) 
AS
DECLARE @rc int = 1;
BEGIN TRY
	INSERT INTO AUDITORIUM(AUDITORIUM, AUDITORIUM_TYPE, AUDITORIUM_CAPACITY, AUDITORIUM_NAME)
			VALUES (@aud, @tpe, @cap, @nme)
	return @rc;
END TRY
BEGIN CATCH
	print '����� ������: ' + convert(varchar(6), error_number());
	print '���������: ' + error_message();
	print '�������: ' + convert(varchar(6), error_severity());
	print '�����: ' + convert(varchar(8), error_state());
	print '����� ������: ' + convert(varchar(8), error_line());
	if error_procedure() is not null
		print '��� ���������: ' + error_procedure();
	return -1;
END CATCH;

declare @rc int;
exec @rc = A_INSERT @aud = '788', @tpe = '��', @cap = 50, @nme = '788';
print '��� ������: ' + convert(varchar(3), @rc);


-- �������

-- 1. ����� �����, � ������� �� ���� ������� � ������ � 01.01.2007 �� 01.01.2008
ALTER FUNCTION FIND_OFF (@beg date, @end date) returns table
AS RETURN
	SELECT d.OFFICE FROM OFFICES as d
						WHERE OFFICE not in (SELECT DISTINCT OFFICE FROM SALESREPS r
									JOIN OFFICES ofs on r.REP_OFFICE = ofs.OFFICE
									JOIN ORDERS ord on ord.REP = r.EMPL_NUM AND ord.ORDER_DATE BETWEEN @beg AND @end)
SELECT * FROM dbo.FIND_OFF('01-01-2007', '01-01-2008');



-- 2. ����� ����� ������� �����, ��������� ������ ����������� (�������� ��������� � ���������� � ������� �� ����������).
ALTER FUNCTION FIND_IT (@param int) returns table
AS RETURN
	SELECT rep.NAME, MAX(convert(float, (ord.AMOUNT/ord.QTY)))[����� ������� �����] FROM SALESREPS rep
						JOIN ORDERS ord ON ord.REP = rep.EMPL_NUM
						WHERE rep.AGE > @param
						GROUP BY rep.NAME
SELECT * FROM dbo.FIND_IT(20);