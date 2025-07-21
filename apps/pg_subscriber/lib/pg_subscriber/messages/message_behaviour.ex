defmodule PgSubscriber.Messages.MessageBehaviour do
  @doc """
  Converts binary data to the Postgres-specific representation of a message (struct).
  """
  @callback from_data!(data :: binary()) :: struct()
end
