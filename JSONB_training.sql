--JSONB training

SELECT '{
  "name": "Tyler",
  "height": 169,
  "hobby": ["coding", "hiking", "cooking"],
  "address": {
	"street": "123 Main St",
	"city": "Anytown",
	"state": "CA",
	"zip": "12345"
  }
}'::json;

--(1)
--::json->'name' / type would be json
--(2)
--::json->>'name' / type would be text
--(3)
--::json->'address'->>'street' / first arrow to access the street, second arrow to extract the value == type would be text
--(4)
--::json->'hobby'->>0 / first arrow to access the hobby , second arrow with index 0 to get the first hobby == type would be text
--(5)
SELECT ('{
  "name": "Tyler",
  "height": 169,
  "hobby": ["coding", "hiking", "cooking"],
  "address": {
	"street": "123 Main St",
	"city": "Anytown",
	"state": "CA",
	"zip": "12345"
  }
}'::json->'height')::int --/gonna return 169 as an int value



--(6)

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  metadata JSONB
);

--(7)

INSERT INTO users (metadata) VALUES
('{
  "name": "Tyler",
  "height": 169,
  "hobby": ["coding", "hiking", "cooking"],
  "address": {
	"street": "123 Main St",
	"city": "Anytown",
	"state": "CA",
	"zip": "12345"
  }
}');

--


INSERT INTO users (metadata) VALUES (
  '{"name": "Sean", 
  "height": 185, 
  "hobby": ["basketball", "football"], 
  "address": {"country": "UK"}
  }'
);



--




INSERT INTO users (metadata) VALUES (
  '{
  "name": "Thor", 
  "height": 190, 
  "hobby": ["tennis", "cooking"], 
  "address": {"country": "UK"}
  }'
);
--(8)

SELECT * 
FROM users 
WHERE (metadata->>'height')::int < 180; --shows all rows where height is less than 180 (we need to extract height as text and then cast it to int for comparison)


--(9)
SELECT * 
FROM users 
WHERE metadata ? 'height'; --shows all rows where we have height key in our json

--(10)

SELECT * 
FROM users 
WHERE metadata->'hobby' ? 'basketball';  --shows all rows where we have basketball

--(11)	


SELECT * 
FROM users 
WHERE metadata->'hobby' ?& array['basketball', 'tennis']; --shows all rows where we have both basketball and tennis ONLY

--(12)


SELECT * 
FROM users 
WHERE metadata->'hobby' ?| array['football', 'cooking']; --shows all rows where we have either football or cooking (or both)




--(13)

SELECT * 
FROM users 
WHERE metadata @> '{"name": "Tyler"}'; --shows all rows where we have name Tyler (exact match)

--(14)
SELECT * 
FROM users 
WHERE metadata @> '{"hobby": ["basketball"]}'; --shows all rows where we have hobby array that contains basketball ONLY
--(15)
SELECT * 
FROM users 
WHERE metadata @> '{"hobby": ["basketball"], "address": {"country": "Japan"}}'; --shows all rows where we have hobby array that contains basketball ONLY and address with country Japan (exact match)