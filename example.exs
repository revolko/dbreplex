DynamicSupervisor.start_child(
  MainApp.DynamicSupervisor,
  {Subscribers.Postgres,
   [
     repl: [host: "localhost", username: "postgres", database: "postgres", password: "postgres"],
     handler: []
   ]}
)

DynamicSupervisor.start_child(
  MainApp.DynamicSupervisor,
  {FilePublisher, ["/tmp/replication.log"]}
)
