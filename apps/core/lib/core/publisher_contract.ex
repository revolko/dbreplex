defmodule Core.PublisherContract do
  @moduledoc """
  Behaviour defining how publisher apps must handle replication messages.
  """

  @typedoc "A replication message struct (Insert/Update/Delete)."
  @type message :: struct()

  @doc """
  Handles an incoming replication message.

  Implement this callback in your publisher app.
  """
  @callback handle_message(message) :: :ok | {:error, term()}
end
