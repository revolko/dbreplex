CREATE TABLE films (
  code integer NOT NULL,
  title varchar(255) NOT NULL
);
ALTER TABLE films REPLICA IDENTITY FULL;

CREATE TABLE distributors (
  did integer NOT NULL,
  name varchar(255) NOT NULL
);
ALTER TABLE distributors REPLICA IDENTITY FULL;

CREATE TABLE test_primary (
  first_name varchar(255) NULL,
  last_name varchar (255) NOT NULL,
  id serial PRIMARY KEY
);

CREATE TABLE test_foreign (
  id serial PRIMARY KEY,
  test_primary_id integer NOT NULL REFERENCES test_primary(id) ON DELETE CASCADE
);

CREATE PUBLICATION postgrex_example FOR ALL TABLES;
