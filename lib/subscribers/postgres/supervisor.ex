defmodule Subscribers.Postgres do
  @moduledoc """
  Entry point for Postgres subscriber.
  """
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg)
  end

  def init(repl: repl_config, handler: handler_config) do
    children = [
      {Subscribers.Postgres.RelationStore, %{}},
      {Subscribers.Postgres.Handler, handler_config},
      {Subscribers.Postgres.Repl, repl_config}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
