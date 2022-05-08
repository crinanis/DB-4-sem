use univer;

-- 1. ����������� �������� ��������� ��� ���������� � ������ PSUBJECT. ��������� ��������� �������������� ����� �� ������ ������� SUBJECT, ����������� ������, ��������������� �� ������e.
-- � ����� ������ ��������� ������ ���������� ���������� �����, ���������� � �������������� �����.


ALTER PROCEDURE PSUBJECT AS
begin
	declare @k int = (select count(*) from SUBJECT);
	select SUBJECT[���], SUBJECT_NAME[����������], PULPIT[�������] from SUBJECT;
	return @k;
end;

declare @res int = 0;
EXEC @res = PSUBJECT;
print '���������� �����= ' + convert(varchar(5), @res);


-- 2. ����� ��������� PSUBJECT � ������� ��������-���� �������� (Object Explorer) SSMS � ����� ���-�������� ���� ������� �������� �� ��������� ���-������ ���������� ALTER.
-- �������� ��������� PSUBJECT, ��������� � ������� 1, ����� �������, ����� ��� ��������� ��� ��������� � ������� @p � @c. �������� @p �������� �������, 
-- ����� ��� VARCHAR(20) � �������� �� ��������� NULL. �������� @� �������� �����-���, ����� ��� INT.
-- ��������� PSUBJECT ������ ����������� �������������� �����, ����������� ������, ��������������� �� ������� ����, �� ��� ���� ��������� ������, ��������������� ���� �������,
-- ��������� ���������� @p. ����� ����, ��������� ����-�� ����������� �������� ��������� ��������� @�, ������ ���������� ����� � �������������� ������, � ����� ���������� �������� � ����� ������,
-- ������ ������ ���������� ��������� (���������� ����� � ������� SUBJECT). 


ALTER PROCEDURE PSUBJECT @p varchar(20), @c int output AS
BEGIN
	DECLARE @k int = (select count(*) FROM SUBJECT);
	PRINT 'parameters @p = ' + @p + ', @c = ' + convert(varchar(3), @c);
	SELECT * FROM SUBJECT WHERE SUBJECT = @p;
	SET @c = @@ROWCOUNT;
	RETURN @k;
END;

DECLARE @k int = 0, @p varchar(30), @r int = 0; 

EXEC @k = PSUBJECT   @p = '��', @c = @r output;
print '����� ���������� ��������� = ' + convert(varchar(3),@k);
print '���������� ��������� ����������� ������� = ' + convert(varchar(3),@r);


-- 3. ������� ��������� ��������� ������� � ������ #SUBJECT. ������������ � ��� �������� ������� ������ ��������������� �������� ��������������� ������ ��������� PSUBJECT, ������������� � ������� 2. 
-- �������� ��������� PSUBJECT ����� �������, ����� ��� �� ��������� ��������� ���������.
-- �������� ����������� INSERT� EXECUTE � ���������������� ���������� PSUBJECT, �������� ������ � ������� #SUBJECT. 

ALTER PROCEDURE PSUBJECT @p varchar(20) AS
BEGIN
	DECLARE @k int = (select count(*) FROM SUBJECT);
	SELECT * FROM SUBJECT WHERE SUBJECT = @p;
END;

CREATE TABLE #SUBJECT
(	���_������� varchar(20) primary key,
	���������� nvarchar(20),
	������� nvarchar(20)
)

INSERT #SUBJECT exec PSUBJECT @p = '��';
INSERT #SUBJECT exec PSUBJECT @p = '��';

SELECT * FROM #SUBJECT;

-- 4. ����������� ��������� � ������ PAUDITORIUM_INSERT. ��������� ��������� ������ ����-��� ���������: @a, @n, @c � @t. �������� @a ����� ��� CHAR(20), �������� @n ����� ��� VAR-CHAR(50), �������� @c ����� ��� INT � �������� �� ��������� 0, �������� @t ����� ��� CHAR(10).
-- ��������� ��������� ������ � ������� AUDITORIUM. �������� �������� AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_CAPACITY � AUDITORIUM_TYPE ����������� ������ �������� �������������� ����������� @a, @n, @c � @t.
-- ��������� PAUDITORIUM_INSERT ������ ��������� �������� TRY/CATCH ��� ��������� ������. � ������ ������������� ������, ��������� ������ ����������� ���������, ���������� ��� ������, ������� ����������� � ����� ��������� � ����������� �������� �����. 
-- ��������� ������ ���������� � ����� ������ ���-����� -1 � ��� ������, ���� ��������� ������ � 1, ���� ���������� �������. 
-- ���������� ������ ��������� � ���������� ���-������� �������� ������, ������� ����������� � �������.


CREATE PROCEDURE PAUDITORIUM_INSERT @a char(20), @n varchar(50), @c int = 0, @t char(10)  AS
DECLARE @rc int = 1;
BEGIN TRY
	INSERT INTO AUDITORIUM(AUDITORIUM, AUDITORIUM_NAME, AUDITORIUM_CAPACITY, AUDITORIUM_TYPE)
			VALUES (@a, @n, @c, @t)
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
exec @rc = PAUDITORIUM_INSERT @a = '2555', @n = '2555', @c = 50, @t = '��';
print '��� ������: ' + convert(varchar(3), @rc);


-- 5. ����������� ��������� � ������ SUBJECT_REPORT, ����������� � ����������� ��-������ ����� ����� �� ������� ��������� �� ���������� �������. � ����� ������ ���� �������� ������� �������� (���� SUBJECT) �� ������� SUBJECT � ���� ������ ����� ������� (������������ ���������� ������� RTRIM). ��������� ����� ������� �������� � ������ @p ���� CHAR(10), ��-����� ������������ ��� �������� ���� �������.
-- � ��� ������, ���� �� ��������� �������� @p ���������� ���������� ��� �������, ��������� ������ ������������ ������ � ���������� ������ � ����������. 
-- ��������� SUBJECT_REPORT ������ ������-���� � ����� ������ ���������� ���������, ������������ � ������. 


CREATE PROCEDURE SUBJECT_REPORT  @p char(10) AS
DECLARE @rc int = 0;
BEGIN TRY   
      DECLARE @tv char(20), @t char(300) = ' ';  
      DECLARE Spisok CURSOR for 
		 SELECT s.SUBJECT FROM SUBJECT s WHERE s.PULPIT = @p;
			if not exists (SELECT s.SUBJECT FROM SUBJECT s WHERE s.PULPIT = @p)
          raiserror('������', 11, 1);
      else 
      OPEN Spisok;	  
		FETCH Spisok INTO @tv;   
		print '������ ��������� �� �������: ';   
		while @@fetch_status = 0                                     
		BEGIN 
			SET @t = rtrim(@tv) + ', ' + @t;  
			SET @rc = @rc + 1;       
			FETCH Spisok INTO @tv; 
		END;   
		print @t;        
	  close Spisok;
    return @rc;
END TRY  
BEGIN CATCH              
	print '������ � ����������' 
    if error_procedure() is not null   
    print '��� ��������� : ' + error_procedure();
    return @rc;
END CATCH; 

DECLARE @rc int;
exec @rc = SUBJECT_REPORT @p = '����';
print '���������� ��������� �� ������� = ' + convert(varchar(3), @rc);


-- 6. ����������� ��������� � ������ PAUDITORI-UM_INSERTX. ��������� ��������� ���� ������� ����������: @a, @n, @c, @t � @tn. 
-- ��������� @a, @n, @c, @t ���������� �������-��� ��������� PAUDITORIUM_INSERT. �����-��������� �������� @tn �������� �������, ����� ��� VARCHAR(50), ������������ ��� ����� �����-��� � ������� AUDITORI-UM_TYPE.AUDITORIUM_TYPENAME.
-- ��������� ��������� ��� ������. ������ ������ ����������� � ������� AUDITORIUM_TYPE. ���-����� �������� AUDITORIUM_TYPE � AUDITO-RIUM_ TYPENAME ����������� ������ �������� �������������� ����������� @t � @tn. ������ ������ ����������� ����� ������ ��������� PAU-DITORIUM_INSERT.
-- ���������� ������ � ������� AUDITORI-UM_TYPE � ����� ��������� PAUDITORI-UM_INSERT ������ ����������� � ������ ����� ����� ���������� � ������� ��������������� SERI-ALIZABLE. 
-- � ��������� ������ ���� ������������� ����-����� ������ � ������� ��������� TRY/CATCH. ��� ������ ������ ���� ���������� � ������� ��-�������������� ��������� � ����������� �������� �����. 
-- ��������� PAUDITORIUM_INSERTX ������ ���������� � ����� ������ �������� -1 � ��� ������, ���� ��������� ������ � 1, ���� ���������� ���-������ ����������� �������. 


CREATE PROCEDURE PAUDITORIUM_INSERTX
     @a char(20), @n nvarchar(50), @c int = 0, @t char(10), @tn varchar(50)   
AS DECLARE @rc int = 1;                            
BEGIN TRY
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;          
    BEGIN TRAN
    INSERT INTO AUDITORIUM_TYPE(AUDITORIUM_TYPE, AUDITORIUM_TYPENAME)
                    values (@t, @tn)
    exec @rc = PAUDITORIUM_INSERT @a, @n, @c, @t;  
    commit tran; 
    return @rc;           
END TRY
BEGIN CATCH 
    print '����� ������  : ' + cast(error_number() as varchar(6));
    print '���������     : ' + error_message();
    print '�������       : ' + cast(error_severity()  as varchar(6));
    print '�����         : ' + cast(error_state()   as varchar(8));
    print '����� ������  : ' + cast(error_line()  as varchar(8));
    if error_procedure() is not  null   
                     print '��� ��������� : ' + error_procedure();
if @@trancount > 0 rollback tran ; 
     return -1;	  
END CATCH;

declare @rc int;  
exec @rc = PAUDITORIUM_INSERTX @a = '722', @n = '722', @c = 78, @t = '����', @tn = '����������';  
print '��� ������ = ' + convert(varchar(3), @rc);  
