# PgSubscriptor

## Howw to run
Currently the `pg_subscriptor` app is connecting to the Postgres instance running on `127.0.0.1:5432`. It expects that 
the database is `postgres`, user `postgres`, and password `postgres`. You need to allow `replication` connection in 
`pg_hba` file (checkout [example](./example) directory).

The Postgres instance must be configured with `wal_level >= logical` and you need to install 
[wal2json plugin](https://github.com/eulerto/wal2json) on the instance server. Note, you need to install the plugin 
for the Postgres version 16.

If everything is properly configured, run the subscriber client:
```bash
mix run --no-halt
```

Upon start, the client opens connection to the Postgres database, configures so called `REPLICATION SLOT`, starts the 
replication and listens on incoming changes. Simply execute insert/delete statement (you can use [pg_randomizer](https://github.com/revolko/pg-randomizer)) and incoming changes will be printed to the console in json format.


## Discussion
I am not sure if `wal2json` is the best plugin to use. By default, Postgres has `pgoutput` plugin for replication, but that yeilded not readable binary result. If we are able to figure out the binary encoding, `pgoutput` might be more efficient than using `json` format.
