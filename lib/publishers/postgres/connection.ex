defmodule Publishers.Postgres.Connection do
  @moduledoc """
  Simple Postgres connection for executing queries.
  """
  require Logger
  @behaviour Postgrex.SimpleConnection

  def child_spec(args) do
    %{
      id: Publishers.Postgres.Connection,
      start: {Publishers.Postgres.Connection, :start_link, [args]}
    }
  end

  def start_link(opts) do
    # Automatically reconnect if we lose connection.
    extra_opts = [
      auto_reconnect: true
    ]

    Postgrex.SimpleConnection.start_link(__MODULE__, :ok, extra_opts ++ opts)
  end

  @impl Postgrex.SimpleConnection
  def init(:ok) do
    {:ok, %{from: nil}}
  end

  @impl Postgrex.SimpleConnection
  def handle_call({:query, query}, from, state) do
    {:query, query, %{state | from: from}}
  end

  @impl Postgrex.SimpleConnection
  def handle_result(results, state) when is_list(results) do
    Postgrex.SimpleConnection.reply(state.from, results)

    {:noreply, state}
  end

  @impl Postgrex.SimpleConnection
  def handle_result(%Postgrex.Error{} = error, state) do
    Postgrex.SimpleConnection.reply(state.from, error)

    {:noreply, state}
  end

  @impl Postgrex.SimpleConnection
  def notify(_, _, _) do
    Logger.warning("Function `notify` not implemented for Postgres connection.")
  end
end
