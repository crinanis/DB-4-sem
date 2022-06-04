--1
--создатьтаблицу с 1 столбцом xml, значения соответсвуют схеме
--внутри xml ещё 2 xml-фрагмента
--один соответсвует, второй нет, вывести почему не соответсвует , изменить и вставить
--найти во всех xml что-нибудь
--2

create xml schema collection Student as 
N'<?xml version="1.0" encoding="utf-16" ?>
<xs:schema attributeFormDefault="unqualified" 
   elementFormDefault="qualified"
   xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="студент">
<xs:complexType><xs:sequence>
<xs:element name="паспорт" maxOccurs="6" minOccurs="1">
  <xs:complexType>
    <xs:attribute name="серия" type="xs:string" use="required" />
    <xs:attribute name="номер" type="xs:unsignedInt" use="required"/>
    <xs:attribute name="дата"  use="required">
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
declare @xml xml='<студент>
		<паспорт серия="КВ" номер="220021700" дата="06.29.2014" />
	</студент>
	<студент>
		<паспорт серия="КС" номер="220021700" дата="06.29.2014" />
		<телефон>+375333834114</телефон>
		<адрес>
			<страна>Беларусь</страна>
			<город>Бобруйск</город>
			<улица>Гагарина</улица>
			<дом>41</дом>
			<квартира>11</квартира>
		</адрес>
	</студент>'
begin try
insert into T1(ID, MY_XML)
	values(1, @xml);
	end try
	begin catch
	print 'Номер ошибки: ' + cast(error_number() as varchar(6));
	print 'Сообщение: ' + error_message();
	print 'Уровень: ' + cast(error_severity() as varchar(6));
	print 'Метка: ' + cast(error_state() as varchar(8));
	print 'Номер строки: ' + cast(error_line() as varchar(8));

	end catch
	

set @xml.modify('
delete /студент[2]/телефон[1]')
set @xml.modify('
delete /студент[2]/адрес[1]')
print cast (@xml as nvarchar(2000))

begin try
insert into T1(ID, MY_XML)
	values(1, @xml);
	end try
	begin catch
	print 'Номер ошибки: ' + cast(error_number() as varchar(6));
	print 'Сообщение: ' + error_message();
	print 'Уровень: ' + cast(error_severity() as varchar(6));
	print 'Метка: ' + cast(error_state() as varchar(8));
	print 'Номер строки: ' + cast(error_line() as varchar(8));

	end catch

select MY_XML.exist('/студент/паспорт') as  a from T1 for xml auto, type;
select * from T1

SELECT MY_XML.query ('/студент/паспорт/серия="КВ"')
FROM dbo.T1
FOR XML AUTO, TYPE;

SELECT MY_XML.value('/студент/паспорт/@серия="КВ"', 'nvarchar(5)') AS Result
FROM dbo.T1
WHERE MY_XML IS NOT NULL
ORDER BY Result DESC
--2
select T1.CITY as '@город',
(select count(*) from SALESREPS where SALESREPS.REP_OFFICE = T1.OFFICE) as '@Кол_во_работников',
(
select S.NAME as '@имя'
from SALESREPS as S
where S.REP_OFFICE = T1.OFFICE
for xml path('REP'), type
)
from OFFICES as T1
group by CITY, OFFICE
for xml path('CITY'), root('CITIES')