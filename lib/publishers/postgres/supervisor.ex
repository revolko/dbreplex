defmodule Publishers.Postgres do
  @moduledoc """
  Entry point for Postgres publisher.
  """
  use Boundary, deps: [Core]
  use Supervisor

  def start_link(init_args) do
    Supervisor.start_link(__MODULE__, init_args)
  end

  @impl Supervisor
  def init(connection: con_config) do
    children = [
      {Publishers.Postgres.Publisher, %{}},
      {Publishers.Postgres.Connection, con_config}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
