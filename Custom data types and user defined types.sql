--The CREATE TYPE command (help me)
Command:     CREATE TYPE
Description: define a new data type
Syntax:
CREATE TYPE name AS                                                  -- A composite type acts like a mini-table inside a single column by grouping multiple different attributes together.
    ( [ attribute_name data_type [ COLLATE collation ] [, ... ] ] )

CREATE TYPE name AS ENUM  -- An ENUM type allows you to define a strict, hardcoded list of permitted text values, which prevents invalid data from being inserted.
    ( [ 'label' [, ... ] ] )

CREATE TYPE name AS RANGE (                            -- A RANGE type is highly useful for storing intervals, such as a start date and an end date, directly within a single field.
    SUBTYPE = subtype
    [ , SUBTYPE_OPCLASS = subtype_operator_class ]
    [ , COLLATION = collation ]
    [ , CANONICAL = canonical_function ]
    [ , SUBTYPE_DIFF = subtype_diff_function ]
    [ , MULTIRANGE_TYPE_NAME = multirange_type_name ]
)

CREATE TYPE name (                                     -- The final and most complex block is for creating a completely new base type from scratch
    INPUT = input_function,                            -- This advanced feature requires specifying underlying input and output functions, and it is mostly used by developers writing custom extensions for the database in the C programming language.
    OUTPUT = output_function
    [ , RECEIVE = receive_function ]
    [ , SEND = send_function ]
    [ , TYPMOD_IN = type_modifier_input_function ]
    [ , TYPMOD_OUT = type_modifier_output_function ]
    [ , ANALYZE = analyze_function ]
    [ , SUBSCRIPT = subscript_function ]
    [ , INTERNALLENGTH = { internallength | VARIABLE } ]
    [ , PASSEDBYVALUE ]
    [ , ALIGNMENT = alignment ]
    [ , STORAGE = storage ]
    [ , LIKE = like_type ]
    [ , CATEGORY = category ]
    [ , PREFERRED = preferred ]
    [ , DEFAULT = default ]
    [ , ELEMENT = element ]
    [ , DELIMITER = delimiter ]
    [ , COLLATABLE = collatable ]
)


--need help with that



--Four forms. User defined types can be of 4 forms:

--(1) composite type, specified by a list of attribute names and data types
--(2) enumerated type, composed of a list of quoted labels
--(3) range type, to create a versatile range
--(4) a completely new scalar base type that you would need, with all features you need to handle correctly in the database.






--Composite type
create type physical_package as (
    height    numeric
  , width     numeric
  , weight    numeric
);

create table packages (
	id            bigint  generated always as identity primary key
, properties    physical_package
);



--Insetring into the table
insert into
packages
  (
     properties
  )
values
  (
     '(10.3,4.0,0.5)'::physical_package
  ),
  (
     '(5,3.0,0.2)'::physical_package
  ),
  (
     '(100,200,400)'::physical_package
  ),
  (
     '(4,10,50)'::physical_package
  ),
  (
     '(12,10,100)'::physical_package
  ),
  (
     '(3.5,5,3.5)'::physical_package
  );


--Querying the table
--easy one
select id,(properties).weight from packages; --this will show the id and the weight of the package.



--harder one
create function categorize_package (
   p  physical_package
) returns text
as
$$
  select
    case when (                                               --[
         case when (p).height>10.0 then true else false end
      or case when (p).width >13.0 then true else false end
      or case when (p).weight>18.0 then true else false end)
    then
			'box'
		else
			'letter'
		end                                                  --] this i function that will filter the packages, or 'box' or 'letter'. 
  ;
$$ language sql;



--(1.1)
select id, properties, categorize_package(properties) from packages; --this will show the id, properties and the category of the package (box or letter).


--(1.2)
select categorize_package(properties), count(*) from packages group by 1; --this will show the category of the package and the count of packages in each category.


--(1.3)
select id, properties from packages where categorize_package(properties)='letter'; --this will show the id and properties of the packages that are categorized as 'letter'.



--(2) ENUM type
create type package_cat as enum ('box','letter'); --this will create an ENUM type called package_cat with two possible values: 'box' and 'letter'.



--(2.1) recreate the function using ENUM type
drop function categorize_package;


--(2.2)
create function categorize_package (
   p  physical_package
) returns package_cat
as
$$
  select                                                     --[
    case when (
      case when (p).height>10.0 then true else false end or
      case when (p).width>13.0 then true  else false end or
      case when (p).weight>18.0 then true else false end
    ) then 'box'::package_cat else 'letter'::package_cat end    --] this is the same function as before but now it returns the ENUM type package_cat instead of text.
  ;
$$ language sql;





--(2.3) This we how we add a enum category to the package_cat ENUM type
alter type package_cat add value 'postcard'; --this will add a new value 'postcard' to the package_cat ENUM type. 


--(2.4) To see all commands for ENUM types
\dT+ package_cat -- this will show all the details of the package_cat ENUM type, including the values it contains.




--(3) Range type
create type delay as range (
	subtype = interval
);                               -- this will create a range type called delay that is based on the interval data type. 




--(3.1) create a table that uses the delay range type
create table packages_with_delay (
		id                bigint generated always as identity primary key
	, properties        physical_package          not null
	, category          package_cat               not null
  , acceptable_delay  delay                     not null
);



-- And insert some data into the table
insert into
packages_with_delay
  (
     properties
    ,category
    ,acceptable_delay
  )
values
  (
     '(10.3,4.0,0.5)'::physical_package
    ,'box'::package_cat
    ,'[3 hours,3 days]'::delay
  ),
  (
     '(5,3.0,0.2)'::physical_package
    ,'letter'::package_cat
    ,'[3 days, 10 days]'
  ),
  (
     '(100,200,400)'::physical_package
    ,'box'::package_cat
    ,'[5 days, 30 days]'
  ),
  (
     '(4,10,50)'::physical_package
    ,'box'::package_cat
    ,'[1 day, 10 days]'
  ),
  (
     '(12,10,100)'::physical_package
    ,'box'::package_cat
    ,'[3 hours, 2 days]'
  ),
  (
     '(3.5,5,3.5)'::physical_package
    ,'postcard'::package_cat
    ,'[3 days, 1 month]'
  );

--(3.2) Querying the table
select
    id
   ,acceptable_delay
from
   packages_with_delay
where
   acceptable_delay @> '[1 day,2 day]'::delay; -- this will show the id and acceptable_delay of the packages that have an acceptable_delay that contains the range '[1 day, 2 day]'. 

--This in RANGE 20 days, 1 mounth
select
    id
   ,acceptable_delay
from
   packages_with_delay
where
   acceptable_delay @> '[20 days,1 month]'::delay; -- this will show the id and acceptable_delay of the packages that have an acceptable_delay that contains the range '[20 days, 1 month]'.

--6 days, 1 mounth
select
    id
   ,acceptable_delay
from
   packages_with_delay
where
   acceptable_delay && '[6 days,1 month]'::delay; -- this will show the id and acceptable_delay of the packages that have an acceptable_delay that overlaps with the range '[6 days, 1 month]'.