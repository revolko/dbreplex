defmodule Core.PublisherContract do
  @moduledoc """
  Behaviour defining how publisher apps must handle replication messages.
  """

  @typedoc "A replication message struct (Insert/Update/Delete)."
  @type message :: struct()

  @typedoc "Name of the publisher server."
  @type server_pid :: GenServer.name()

  @doc """
  Handles an incoming replication message.

  Implement this callback in your publisher app.
  """
  @callback handle_message(server_pid, message) :: :ok | {:error, term()}
end
