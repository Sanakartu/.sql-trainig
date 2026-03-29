--Syntax
Command: CREATE DOMAIN
Description: define a new domain
Syntax:
CREATE DOMAIN name [ AS ] data_type
	[ COLLATE collation ] -- this is for string types, it specifies how to sort and compare values
	[ DEFAULT expression ] -- this is what will be used if no value is provided
	[ constraint [ ... ] ] --this is what domain will check


--Example
CREATE DOMAIN positive_integer AS INTEGER
    [ CONSTRAINT constraint_name ]
{ NOT NULL | NULL | CHECK (expression) } -- this is the constraint for the domain
-- NOT NULL means that the value cannot be }
--                                         }and if it is not/null it will be rejected by the database
-- NULL means that the value can be null   }


--Table from the site
                              Table "public.person"
   Column   |  Type   | Collation | Nullable |              Default
------------+---------+-----------+----------+------------------------------------
 id         | integer |           | not null | nextval('person_id_seq'::regclass)
 firstname  | text    |           | not null |
 lastname   | text    |           | not null |
 birth_date | date    |           |          |
 email      | text    |           | not null |
Indexes:
    "person_pkey" PRIMARY KEY, btree (id)create table person



--Example of not using the domain
create table person_using_checks (
    id          integer generated always as identity primary key
  , firstname   text not null
  , lastname    text not null
  , birth_date  date
  , email       text not null
  , check (birth_date>'1930-01-01'::date)
  , check (email ~ '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$') -- just two checks
);


--(1)
insert into person_using_checks (firstname,lastname,birth_date,email)
values ('Starman','Sky','1972-04-28','unknown'); -- this will be rejected because the email does not match the regex pattern

--(2)
insert into person_using_checks (firstname,lastname,birth_date,email)
values ('Starman','Sky','1972-04-28','unknown'); -- this will be rejected because the email does not match the regex pattern and the birth_date is before 1930-01-01


--(3)
insert into person_using_checks (firstname,lastname,birth_date,email)
values ('Jhon','Doe','1970-01-01'::date,'john@doe.org'); -- this will be rejected because the birth_date is before 1930-01-01



--Example of using the domain
create domain date_of_birth as date
	check (value > '1930-01-01'::date)
;
create domain valid_email as text
	not null
	check (value ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')
;

--Example of using the domain in a table

create table person_using_domains (
    id          integer generated always as identity primary key
  , firstname   text not null
  , lastname    text not null
  , birth_date  date_of_birth --here we using domains instead of checks
  , email       valid_email
);

--commands to display your domains 
\dD -- this will show all the domains in the database
\dD+ -- this will show all the domains in the database with more details


--if you wanna change your check some where (create domain date_of_birth as date check (value > '1930-01-01'::date)) like umm you need to change the date to 1950-01-01 you can do it like this
ALTER DOMAIN date_of_birth
  DROP CONSTRAINT date_of_birth_check, -- this will drop the old constraint
  ADD CONSTRAINT date_of_birth_check CHECK (value > '1950-01-01'::date); -- this will add the new constraint

--If you wanna change the data and do not check the existing data you need write
ALTER DOMAIN date_of_birth
  DROP CONSTRAINT date_of_birth_check, -- this will drop the old constraint
  ADD CONSTRAINT date_of_birth_check CHECK (value > '1950-01-01'::date) NOT VALID; -- this will add the new constraint but it will not check the existing data