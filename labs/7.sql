use UNIVER;

--1. ����������� ������������� � ������ �������������. ������������� ������ ���� ��������� �� ������ SELECT-������� � ������� TEACHER
--� ��������� ��������� �������: ��� (TEACHER), ��� ������������� (TEACHER_NAME), ��� (GENDER), ��� ������� (PULPIT). 

CREATE VIEW [�������������] AS
	 SELECT	  TEACHER[���],
			  TEACHER_NAME[��� �������������],
			  GENDER[���],
			  PULPIT[��� �������]
	FROM TEACHER;

SELECT * FROM �������������;	


--2. ����������� � ������� ������������� � ������ ���������� ������. ������������� ������ ���� ��������� �� ������ SELECT-������� � �������� FACULTY � PULPIT.
--������������� ������ ��������� ��������� �������: ��������� (FACULTY.FACULTY_NAME), ���������� ������ (����������� �� ������ ����� ������� PULPIT). 

CREATE VIEW [����������_������] AS
	SELECT FACULTY.FACULTY_NAME[���������],
		   COUNT(*)[���������� ������]
	FROM PULPIT join FACULTY 
	on PULPIT.FACULTY=FACULTY.FACULTY
	group by FACULTY.FACULTY_NAME

SELECT * FROM ����������_������


--3. ����������� � ������� ������������� � ������ ���������. ������������� ������ ���� ��������� �� ������ ������� AUDITORIUM � ��������� �������: ��� (AUDITORIUM), ������������ ��������� (AUDITORIUM_NAME). 
--������������� ������ ���������� ������ ���������� ��������� (� ������� AUDITORIUM_TYPE ������, ������������ � ������� ��) � ��������� ���������� ��������� INSERT, UPDATE � DELETE.

CREATE VIEW [���������] AS
	SELECT AUDITORIUM[���], AUDITORIUM_NAME[������������ ���������], AUDITORIUM_TYPE[��� ���������]  
	FROM AUDITORIUM WHERE AUDITORIUM_TYPE like '��%'

SELECT * FROM ���������

INSERT ��������� values ('601-4', '601-4', '��');
UPDATE ��������� SET [��� ���������] = '��';
DELETE FROM ��������� WHERE [������������ ���������] = '597'


--4. ����������� � ������� ������������� � ������ ����������_���������. 
--������������� ������ ���� ��������� �� ������ SELECT-������� � ������� AUDITORIUM � ��������� ��������� �������: ��� (AUDITORIUM), ������������ ��������� (AUDITORIUM_NAME). 
--������������� ������ ���������� ������ ���������� ��������� (� ������� AUDITORIUM_TYPE ������, ������������ � �������� ��). 
--���������� INSERT � UPDATE ���������-��, �� � ������ �����������, ����������� ������ WITH CHECK OPTION. 

ALTER VIEW [���������] AS
	SELECT AUDITORIUM[���], AUDITORIUM_NAME[������������ ���������], AUDITORIUM_TYPE[��� ���������]  
	FROM AUDITORIUM WHERE AUDITORIUM_TYPE like '��%' WITH CHECK OPTION;

SELECT * FROM ���������

INSERT ��������� values ('601-4', '601-4', '��');
INSERT ��������� values ('603-4', '603-4', '��');
INSERT ��������� values ('605-4', '605-4', '��');


--5. ����������� ������������� � ������ ����������. ������������� ������ ���� ��������� �� ������ SELECT-������� � ������� SUBJECT, ���������� ��� ���������� � ���������� ������� � ��������� ��������� �������:
--��� (SUBJECT), ������������ ���������� (SUBJECT_NAME) � ��� ������� (PULPIT). ������������ TOP � ORDER BY.

CREATE VIEW ����������(���, ������������_����������, ���_�������) AS
	SELECT TOP 10 SUBJECT, SUBJECT_NAME, PULPIT.PULPIT
	FROM SUBJECT join PULPIT on SUBJECT.PULPIT=PULPIT.PULPIT
	ORDER BY SUBJECT_NAME asc;

SELECT * from ����������;


--6. �������� ������������� ����������_������, ��������� � ������� 2 ���, ����� ��� ���� ��������� � ������� ��������. 
--������������������ �������� ������������� ������������� � ������� ��������. ����������: ������������ ����� SCHEMABINDING. 

ALTER VIEW [����������_������] WITH SCHEMABINDING AS
	SELECT f.FACULTY_NAME[���������],
	count(*)[���������� ������]
	FROM dbo.PULPIT p join dbo.FACULTY f
	on p.FACULTY=f.FACULTY
	group by f.FACULTY_NAME 

INSERT INTO [����������_������] values ('RRRR', 10);