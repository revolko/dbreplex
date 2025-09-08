DynamicSupervisor.start_child(
  MainApp.DynamicSupervisor,
  {PgSubscriber,
   [
     repl: [host: "localhost", username: "postgres", database: "postgres", password: "postgres"],
     handler: []
   ]}
)

DynamicSupervisor.start_child(
  MainApp.DynamicSupervisor,
  {FilePublisher, ["/tmp/replication.log"]}
)
