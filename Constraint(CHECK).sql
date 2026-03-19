--Constraint(CHECK)

--(1)
CREATE TABLE products (
  name TEXT,
  price NUMERIC,
  CONSTRAINT valid_price CHECK (price > 0),        --price cant be less than or equal to 0
  CONSTRAINT name_length CHECK (length(name) > 0) --name cant be empty
);


--(1.2)
INSERT INTO products (name, price) VALUES ('Mug', 10); --valid


--(1.3)
INSERT INTO products (name, price) VALUES ('T-Shirt', -5); --invalid, price is negative
--also
INSERT INTO products (name, price) VALUES ('Coffee', 0); --invalid, price is zero

--(1.4)
INSERT INTO products (name, price) VALUES ('', 15); --invalid, name is empty

--(2)
CREATE TABLE products (
  name TEXT,
  price NUMERIC,
  discounted_price NUMERIC,
  CHECK (discounted_price < price AND discounted_price > 0) --discounted_price must be less than price and bigger than 0 / selfexplanatory i guess :)
);


--(3)
CREATE TABLE scheduled_posts (
  id SERIAL PRIMARY KEY,
  content TEXT,
  post_at TIMESTAMP CHECK (post_at > now()) --post_at must be in the future / as it was sed in vid
);


--(4)
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name TEXT,
  birth_date DATE CHECK (birth_date <= now() - interval '18 years') --birth_date must be at least 18 years ago / as it was sed in vid, yay
);


--(5)
CREATE TABLE profiles (
  id SERIAL PRIMARY KEY,
  email TEXT CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'), -- symvol ~* is used for SQL DB to ignor CApITAL or small letters, symvol ^ is used to mark the start of the string, $ is used to mark the end of the string, symvol + is used to combine the first part (^[A-Za-z0-9._%+-]) with the second part ([A-Za-z0-9.-]) and the symvol (@), AND THE THIRD ONE (\.[A-Za-z]{2,}$) to make sure the email is in the correct format, symvol / just ....... for putting a dot, the last part of the regex \.[A-Za-z]{2,} is used to check for the domain extension, it must be at least 2 characters long and can only contain letters
  username TEXT
);

