defmodule PgSubscriber do
  @moduledoc """
  Supervisor for Postgres subscriber.
  """
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg)
  end

  def init(repl: repl_config, handler: handler_config) do
    children = [
      {PgSubscriber.RelationStore, %{}},
      {PgSubscriber.Handler, handler_config},
      {PgSubscriber.Repl, repl_config}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
