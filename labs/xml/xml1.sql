--1
--�������������� � 1 �������� xml, �������� ������������ �����
--������ xml ��� 2 xml-���������
--���� ������������, ������ ���, ������� ������ �� ������������ , �������� � ��������
--����� �� ���� xml ���-������
--2

create xml schema collection Student as 
N'<?xml version="1.0" encoding="utf-16" ?>
<xs:schema attributeFormDefault="unqualified" 
   elementFormDefault="qualified"
   xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="�������">
<xs:complexType><xs:sequence>
<xs:element name="�������" maxOccurs="6" minOccurs="1">
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
</xs:sequence></xs:complexType>
</xs:element></xs:schema>';
drop XML SCHEMA COLLECTION Student;

create table T1
(
	ID int,
	MY_XML xml(Student)
)
declare @xml xml='<�������>
		<������� �����="��" �����="220021700" ����="06.29.2014" />
	</�������>
	<�������>
		<������� �����="��" �����="220021700" ����="06.29.2014" />
		<�������>+375333834114</�������>
		<�����>
			<������>��������</������>
			<�����>��������</�����>
			<�����>��������</�����>
			<���>41</���>
			<��������>11</��������>
		</�����>
	</�������>'
begin try
insert into T1(ID, MY_XML)
	values(1, @xml);
	end try
	begin catch
	print '����� ������: ' + cast(error_number() as varchar(6));
	print '���������: ' + error_message();
	print '�������: ' + cast(error_severity() as varchar(6));
	print '�����: ' + cast(error_state() as varchar(8));
	print '����� ������: ' + cast(error_line() as varchar(8));

	end catch
	

set @xml.modify('
delete /�������[2]/�������[1]')
set @xml.modify('
delete /�������[2]/�����[1]')
print cast (@xml as nvarchar(2000))

begin try
insert into T1(ID, MY_XML)
	values(1, @xml);
	end try
	begin catch
	print '����� ������: ' + cast(error_number() as varchar(6));
	print '���������: ' + error_message();
	print '�������: ' + cast(error_severity() as varchar(6));
	print '�����: ' + cast(error_state() as varchar(8));
	print '����� ������: ' + cast(error_line() as varchar(8));

	end catch

select MY_XML.exist('/�������/�������') as  a from T1 for xml auto, type;
select * from T1

SELECT MY_XML.query ('/�������/�������/�����="��"')
FROM dbo.T1
FOR XML AUTO, TYPE;

SELECT MY_XML.value('/�������/�������/@�����="��"', 'nvarchar(5)') AS Result
FROM dbo.T1
WHERE MY_XML IS NOT NULL
ORDER BY Result DESC
--2
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