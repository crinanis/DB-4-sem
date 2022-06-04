use TestIsolation;
go

drop table testXML;

create table testXML (
	id int primary key identity,
	xml_data xml
);

select left(newid(),5);

drop XML SCHEMA COLLECTION TestSchema;

create xml schema collection TestSchema as 
N'<?xml version="1.0" encoding="utf-16" ?>
<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" xmlns:xs="http://www.w3.org/2001/XMLSchema">
	<xs:element name="xml_data">
		<xs:complexType>
			<xs:sequence>
				<xs:element name="id" type="xs:unsignedInt"/>
				<xs:element name="username" type="xs:string"/>
				<xs:element name="FIO" maxOccurs="1" minOccurs="1">
				  <xs:complexType>
					<xs:attribute name="name" type="xs:string" use="required" />
					<xs:attribute name="surname" type="xs:string" use="required"/>
					<xs:attribute name="othc" type="xs:string" use="required"/>
					<xs:attribute name="UUID"  use="required">
						<xs:simpleType>
							<xs:restriction base ="xs:string">
								<xs:pattern value="\w{5}"/>
							</xs:restriction>
						</xs:simpleType>
					</xs:attribute>
				  </xs:complexType>
				</xs:element>
			</xs:sequence>
		</xs:complexType>
	</xs:element>
</xs:schema>';


alter table testXML alter column xml_data xml(TestSchema);



declare @testfile xml;
set @testfile = '<xml_data>
	<id>2</id>
	<username>NTN_code</name>
	<FIO name="Anton" surname="Tkachou" othc="Alex" UUID="aaaaa"/>
</xml_data>'
go

drop procedure insert_into_testXML;
go

create procedure insert_into_testXML @xml_variable xml as
	begin
		begin try
			insert into testXML values (@xml_variable);
			print('SUCCESS! Insert into testXML!')
			return 0;
		end try
		begin catch 
			print('Error number: ' + cast(error_number() as nvarchar));
			print('Error description: ' + error_message());
			return -1;
		end catch
	end


declare @testfile1 xml;
set @testfile1 = '<xml_data>
<id>2</id>
<username>NTN_code</username>
<FIO name="Anton" othc="Alex" UUID="aaa2211"/>
</xml_data>'
go


declare @result int;
exec @result = insert_into_testXML '<xml_data>
<id>3</id>
<username>Dimitriadi</username>
<FIO name="Anton" surname="Dimitriadi" othc="Alex" UUID="bbbbb"/>
</xml_data>';

select * from testXML;



select xml_data.query('/xml_data/username') from testXML;


select xml_data.query('/xml_data/FIO[@name="Dima"]') from testXML;

select xml_data.value('(xml_data/FIO/@name)[1]', 'varchar(20)') from testXML;

select xml_data.value('(xml_data/username)[1]', 'varchar(20)') from testXML where id =1 ;

