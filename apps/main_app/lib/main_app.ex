defmodule MainApp do
  @moduledoc false

  use Application

  @subscriber Application.compile_env(:main_app, :subscriber, nil)
  @replicator Application.compile_env(:main_app, :replicator, nil)
  @publisher Application.compile_env(:main_app, :publisher, nil)

  @impl true
  def start(_type, _args) do
    children = [
      @subscriber,
      {@replicator,
       [host: "localhost", database: "postgres", username: "postgres", password: "postgres"]},
      {@publisher, "/tmp/replication.log"},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MainApp.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
