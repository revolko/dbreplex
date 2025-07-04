defmodule PgSubscriber.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PgSubscriber.Handler,
      {PgSubscriber.Repl,
       [host: "localhost", database: "postgres", username: "postgres", password: "postgres"]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PgSubscriber.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
