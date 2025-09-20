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

CREATE PUBLICATION postgrex_example FOR ALL TABLES;
ALTER SYSTEM SET wal_level = logical;
