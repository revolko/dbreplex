# DbSubscriptor

## Configuration
The application needs to have configured the `subscriber`, `replicator` and `publisher` implementations in `config/config.exs`:
```elixir
config :main_app,
  subscriber: PgSubscriber.Handler,
  replicator: PgSubscriber.Repl,
  publisher: FilePublisher
```

If everything is properly configured, run the application:
```bash
mix run --no-halt
```
