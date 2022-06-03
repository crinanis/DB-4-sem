

-- 1. ����������� �������� �������� XML-��������� � ������ PATH �� ������� TEACHER ��� �������������� ������� ����. 

SELECT PULPIT.FACULTY[���������/@���], TEACHER.PULPIT[���������/�������/@���], TEACHER.TEACHER_NAME[���������/�������/�������������/@���]
	    FROM TEACHER inner join PULPIT ON TEACHER.PULPIT = PULPIT.PULPIT
			   WHERE TEACHER.PULPIT = '����' FOR XML PATH, ROOT('������_��������������_�������_����');

-- 2. ����������� �������� �������� XML-��������� � ������ AUTO �� ������ SELECT-������� � �������� AUDITORIUM 
-- � AUDITORIUM_TYPE, ������� �������� ��������� �������: ������������ ���������, ������������ ���� ��������� � �����������. ����� ������ ���������� ���������. 

SELECT tpe.AUDITORIUM_TYPENAME, a.AUDITORIUM_TYPE, a.AUDITORIUM_CAPACITY 
		FROM AUDITORIUM a inner join AUDITORIUM_TYPE tpe ON a.AUDITORIUM_TYPE = tpe.AUDITORIUM_TYPE WHERE tpe.AUDITORIUM_TYPENAME = '����������'
		ORDER BY tpe.AUDITORIUM_TYPENAME FOR XML AUTO, ROOT('������_���������'), ELEMENTS;

-- 3. ����������� XML-��������, ���������� ������ � ���� ����� ������� �����������, ������� ������� �������� � ������� SUBJECT. 
-- ����������� ��������, ����������� ������ � ����������� �� XML-��������� � ����������� �� � ������� SUBJECT. 
-- ��� ���� ��������� ��������� ������� OPENXML � ����������� INSERT� SELECT. 
-- <?xml version="1.0" encoding="windows-1251"?>

DECLARE @h int = 0,
	@x varchar(2000)='<?xml version="1.0" encoding="windows-1251" ?>
	<����������>
					   	<���������� ���="����" ��������="������������ ��������� � �������" �������="����" />
						 <���������� ���="���" ��������="������ ������ ����������" �������="����" />
						 <���������� ���="���" ��������="����������� ���������� ���������������� � Internet" �������="����" />
	</����������>';
	   EXEC sp_xml_preparedocument @h OUTPUT, @x; --���������� ���������

INSERT INTO SUBJECT SELECT[���], [��������], [�������] FROM OPENXML(@h, '/����������/����������', 0)
    WITH([���] char(10), [��������] varchar(100), [�������] char(20));
	SELECT * FROM SUBJECT
DELETE FROM SUBJECT WHERE SUBJECT.SUBJECT='����' or SUBJECT.SUBJECT='���' or SUBJECT.SUBJECT='���'

-- 4. ��������� ������� STUDENT ����������� XML-���������, ���������� ���������� ������ ��������: ����� � ����� ��������, ������ �����, ���� ������ � ����� ��������. 
-- ����������� ��������, � ������� ������� �������� INSERT, ����������� ������ � XML-��������.
-- �������� � ���� �� �������� �������� UPDATE, ���������� ������� INFO � ����� ������ ������� STUDENT � �������� SELECT, ����������� �������������� �����, ����������� ��������������� �� �������. 
-- � SELECT-������� ������������ ������ QUERY � VALUEXML-����.
 
INSERT INTO STUDENT(IDGROUP, NAME, BDAY, INFO)
	VALUES(5, '�������� �. �.', '07.10.2003',
	'<�������>
		<������� �����="A�" �����="3176888" ����="04.17.2017" />
		<�������>+375333303546</�������>
		<�����>
			<������>��������</������>
			<�����>�����</�����>
			<�����>�������������</�����>
			<���>12</���>
			<��������>155</��������>
		</�����>
	</�������>');
SELECT * FROM STUDENT WHERE NAME = '�������� �. �.';

UPDATE STUDENT set INFO = 
	'<�������>
		<������� �����="A�" �����="3176888" ����="04.17.2017" />
		<�������>375333303546</�������>
		<�����>
			<������>��������</������>
			<�����>�����</�����>
			<�����>�������������</�����>
			<���>12</���>
			<��������>155</��������>
		</�����>
     </�������>' WHERE NAME='�������� �. �.'

SELECT NAME[���], INFO.value('(�������/�������/@�����)[1]', 'char(2)')[����� ��������], INFO.value('(�������/�������/@�����)[1]', 'varchar(20)')[����� ��������],
	INFO.query('�������/�����')[�����]
		from  STUDENT
			where NAME = '�������� �. �.';

-- 5. �������� (ALTER TABLE) ������� STUDENT � ���� ������ UNIVER ����� �������, ����� �������� ��������������� ������� � ������ INFO ���������������� ���������� XML-���� (XML SCHEMACOLLECTION), �������������� � ������ �����. 
-- ����������� ��������, ��������������� ���� � ������������� ������ (��������� INSERT � UPDATE) � ������� INFO ������� STUDENT, ��� ���������� ������, ��� � ����������.
-- ����������� ������ XML-����� � �������� �� � ��������� XML-���� � �� UNIVER.

create xml schema collection Student as 
N'<?xml version="1.0" encoding="utf-16" ?>
<xs:schema attributeFormDefault="unqualified" 
   elementFormDefault="qualified"
   xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="�������">
<xs:complexType><xs:sequence>
 <xs:element name="�������" maxOccurs="1" minOccurs="1">
  <xs:complexType>
    <xs:attribute name="�����" type="xs:string" use="required" />
    <xs:attribute name="�����" type="xs:unsignedInt" use="required"/>
    <xs:attribute name="����"  use="required">
	<xs:simpleType>  <xs:restriction base ="xs:string">
		<xs:pattern value="[0-9]{2}.[0-9]{2}.[0-9]{4}"/>
	 </xs:restriction> 	</xs:simpleType>
    </xs:attribute>
  </xs:complexType>
 </xs:element>
 <xs:element name="�������" maxOccurs="3" type="xs:string"/>
 <xs:element name="�����">   
 <xs:complexType><xs:sequence>
   <xs:element name="������" type="xs:string" />
   <xs:element name="�����" type="xs:string" />
   <xs:element name="�����" type="xs:string" />
   <xs:element name="���" type="xs:string" />
   <xs:element name="��������" type="xs:string" />
 </xs:sequence></xs:complexType> 
 </xs:element>
</xs:sequence></xs:complexType>
</xs:element></xs:schema>';

alter table STUDENT alter column INFO xml(Student);
drop XML SCHEMA COLLECTION Student;
SELECT Name, INFO from STUDENT where NAME='�������� �. �.'


use Exam_scheme
select T1.CITY as '@�����',
(select count(*) from SALESREPS where SALESREPS.REP_OFFICE = T1.OFFICE) as '@���_��_����������',
(
select S.NAME as '@���'
from SALESREPS as S
where S.REP_OFFICE = T1.OFFICE
for xml path('REP'), type
)
from OFFICES as T1
group by CITY, OFFICE
for xml path('CITY'), root('CITIES')
