# dbreplex

## Prerequisite
 * erlang (OTP 28)
 * elixir (1.18.4)
 * docker (to run examples)

## How to run
Either start the application with iex console:
```bash
iex -S mix run --no-halt
```

Or use [example.exs](./example.exs) script to quickly startup Subscribers.Postgres with Publishers.File:
```bash
iex -S mix run example.exs
```

`Subscribers.Postgres` requires running Postgres database. Checkout [postgres example](./apps/pg_subscriber/example/) for a quick setup.
Make sure that `Publishers.File` points to the existing location of your system (file does not need to exist, but parent
directories must).

Finally, connect to a subscriber and execute INSERT/UPDATE/DELETE statement. The statement will be logged and saved by all
publishers (in case of
Publishers.File the statement is saved to a file).

## Subscribers

### Subscribers.Postgres :rocket:
Subscriber for Postgres database. The subscriber creates logical replication connection to Postgres database. The replication
connection makes database to push replication messages to the subscriber (push-based communication).

#### Features
 * :x: pre-configuration of the source database
    * for now, database must correctly configure replication and publishing settings 
      (see [postgres example](./apps/pg_subscriber/example/init.sql))
 * database statements:
    * :white_check_mark: INSERT
    * :white_check_mark: UPDATE
    * :white_check_mark: DELETE
    * :x: TRUNCATE
 * :white_check_mark: tables without primary keys
 * :white_check_mark: tables with primary keys
 * :white_check_mark: tables with foreign keys
 * :x: full initial load

### Oracle :pushpin:

### MSSQL :pushpin:

### SQLite :pushpin:

## Publishers

### Publishers.File :rocket:
Publisher storing replication messages to files.

#### Features
 * serialized database messages:
    * :white_check_mark: INSERT
    * :white_check_mark: UPDATE
    * :white_check_mark: DELETE
    * :x: TRUNCATE

### S3Publisher :pushpin:

### PgPublisher :pushpin:
