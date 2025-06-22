defmodule PgSubscriptor.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # {Task.Supervisor, name: PgSubscriptor.TaskSupervisor},
      # {PgSubscriptor, 4321},
      {PgRepl, [host: "localhost", database: "postgres", username: "postgres", password: "postgres"]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PgSubscriptor.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
