defmodule MainApp do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PgSubscriber.Handler,
      {PgSubscriber.Repl,
       [host: "localhost", database: "postgres", username: "postgres", password: "postgres"]},
      {FilePublisher, "/tmp/replication.log"},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MainApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
