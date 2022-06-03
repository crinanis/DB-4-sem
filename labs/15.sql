

-- 1. Разработать сценарий создания XML-документа в режиме PATH из таблицы TEACHER для преподавателей кафедры ИСиТ. 

SELECT PULPIT.FACULTY[факультет/@код], TEACHER.PULPIT[факультет/кафедра/@код], TEACHER.TEACHER_NAME[факультет/кафедра/преподаватель/@код]
	    FROM TEACHER inner join PULPIT ON TEACHER.PULPIT = PULPIT.PULPIT
			   WHERE TEACHER.PULPIT = 'ИСиТ' FOR XML PATH, ROOT('Список_преподавателей_кафедры_ИСиТ');

-- 2. Разработать сценарий создания XML-документа в режиме AUTO на основе SELECT-запроса к таблицам AUDITORIUM 
-- и AUDITORIUM_TYPE, который содержит следующие столбцы: наименование аудитории, наименование типа аудитории и вместимость. Найти только лекционные аудитории. 

SELECT tpe.AUDITORIUM_TYPENAME, a.AUDITORIUM_TYPE, a.AUDITORIUM_CAPACITY 
		FROM AUDITORIUM a inner join AUDITORIUM_TYPE tpe ON a.AUDITORIUM_TYPE = tpe.AUDITORIUM_TYPE WHERE tpe.AUDITORIUM_TYPENAME = 'Лекционная'
		ORDER BY tpe.AUDITORIUM_TYPENAME FOR XML AUTO, ROOT('Список_аудиторий'), ELEMENTS;

-- 3. Разработать XML-документ, содержащий данные о трех новых учебных дисциплинах, которые следует добавить в таблицу SUBJECT. 
-- Разработать сценарий, извлекающий данные о дисциплинах из XML-документа и добавляющий их в таблицу SUBJECT. 
-- При этом применить системную функцию OPENXML и конструкцию INSERT… SELECT. 
-- <?xml version="1.0" encoding="windows-1251"?>

DECLARE @h int = 0,
	@x varchar(2000)='<?xml version="1.0" encoding="windows-1251" ?>
	<дисциплины>
					   	<дисциплина код="КГиГ" название="Компьютерная геометрия и графика" кафедра="ИСиТ" />
						 <дисциплина код="ОЗИ" название="Основы защиты информации" кафедра="ИСиТ" />
						 <дисциплина код="СТП" название="Современные технологии программирования в Internet" кафедра="ИСиТ" />
	</дисциплины>';
	   EXEC sp_xml_preparedocument @h OUTPUT, @x; --подготовка документа

INSERT INTO SUBJECT SELECT[код], [название], [кафедра] FROM OPENXML(@h, '/дисциплины/дисциплина', 0)
    WITH([код] char(10), [название] varchar(100), [кафедра] char(20));
	SELECT * FROM SUBJECT
DELETE FROM SUBJECT WHERE SUBJECT.SUBJECT='КГиГ' or SUBJECT.SUBJECT='ОЗИ' or SUBJECT.SUBJECT='СТП'

-- 4. Используя таблицу STUDENT разработать XML-структуру, содержащую паспортные данные студента: серию и номер паспорта, личный номер, дата выдачи и адрес прописки. 
-- Разработать сценарий, в который включен оператор INSERT, добавляющий строку с XML-столбцом.
-- Включить в этот же сценарий оператор UPDATE, изменяющий столбец INFO у одной строки таблицы STUDENT и оператор SELECT, формирующий результирующий набор, аналогичный представленному на рисунке. 
-- В SELECT-запросе использовать методы QUERY и VALUEXML-типа.
 
INSERT INTO STUDENT(IDGROUP, NAME, BDAY, INFO)
	VALUES(5, 'Буданова К. А.', '07.10.2003',
	'<студент>
		<паспорт серия="AВ" номер="3176888" дата="04.17.2017" />
		<телефон>+375333303546</телефон>
		<адрес>
			<страна>Беларусь</страна>
			<город>Брест</город>
			<улица>Волгоградская</улица>
			<дом>12</дом>
			<квартира>155</квартира>
		</адрес>
	</студент>');
SELECT * FROM STUDENT WHERE NAME = 'Буданова К. А.';

UPDATE STUDENT set INFO = 
	'<студент>
		<паспорт серия="AВ" номер="3176888" дата="04.17.2017" />
		<телефон>375333303546</телефон>
		<адрес>
			<страна>Беларусь</страна>
			<город>Брест</город>
			<улица>Волгоградская</улица>
			<дом>12</дом>
			<квартира>155</квартира>
		</адрес>
     </студент>' WHERE NAME='Буданова К. А.'

SELECT NAME[ФИО], INFO.value('(студент/паспорт/@серия)[1]', 'char(2)')[Серия паспорта], INFO.value('(студент/паспорт/@номер)[1]', 'varchar(20)')[Номер паспорта],
	INFO.query('студент/адрес')[Адрес]
		from  STUDENT
			where NAME = 'Буданова К. А.';

-- 5. Изменить (ALTER TABLE) таблицу STUDENT в базе данных UNIVER таким образом, чтобы значения типизированного столбца с именем INFO контролировались коллекцией XML-схем (XML SCHEMACOLLECTION), представленной в правой части. 
-- Разработать сценарии, демонстрирующие ввод и корректировку данных (операторы INSERT и UPDATE) в столбец INFO таблицы STUDENT, как содержащие ошибки, так и правильные.
-- Разработать другую XML-схему и добавить ее в коллекцию XML-схем в БД UNIVER.

create xml schema collection Student as 
N'<?xml version="1.0" encoding="utf-16" ?>
<xs:schema attributeFormDefault="unqualified" 
   elementFormDefault="qualified"
   xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="студент">
<xs:complexType><xs:sequence>
 <xs:element name="паспорт" maxOccurs="1" minOccurs="1">
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
 <xs:element name="телефон" maxOccurs="3" type="xs:string"/>
 <xs:element name="адрес">   
 <xs:complexType><xs:sequence>
   <xs:element name="страна" type="xs:string" />
   <xs:element name="город" type="xs:string" />
   <xs:element name="улица" type="xs:string" />
   <xs:element name="дом" type="xs:string" />
   <xs:element name="квартира" type="xs:string" />
 </xs:sequence></xs:complexType> 
 </xs:element>
</xs:sequence></xs:complexType>
</xs:element></xs:schema>';

alter table STUDENT alter column INFO xml(Student);
drop XML SCHEMA COLLECTION Student;
SELECT Name, INFO from STUDENT where NAME='Буданова К. А.'


use Exam_scheme
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
