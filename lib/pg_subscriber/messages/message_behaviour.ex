defmodule PgSubscriber.Messages.MessageBehaviour do
  @doc """
  Converts binary data to the Postgres-specific representation of a message (struct).
  """
  @callback from_data(data :: binary()) ::
              {:ok, pg_message :: struct()} | {:error, reason :: any()}

  @optional_callbacks from_data: 1
end
