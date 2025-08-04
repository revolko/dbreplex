defmodule PgSubscriber.Messages.Insert do
  @moduledoc """
  Represents Postgres INSERT operation in the database replication stream.
  """
  require Logger
  alias PgSubscriber.Messages.MessageBehaviour
  alias PgSubscriber.Column
  alias PgSubscriber.Utils
  alias PgSubscriber.TupleData

  @behaviour MessageBehaviour

  @type t :: %__MODULE__{
          relation_oid: Utils.oid(),
          columns: [Column.t()]
        }

  @enforce_keys [:relation_oid, :columns]
  defstruct @enforce_keys

  @impl MessageBehaviour
  def from_data(data) do
    with <<relation_oid::32, "N", rest::binary>> <- data,
         {:ok, new_data, <<>>} <- TupleData.get_tuple_data(rest) do
      {:ok,
       %__MODULE__{
         relation_oid: relation_oid,
         columns: new_data.columns
       }}
    else
      {:error, reason} ->
        {:error, reason}

      _ ->
        Logger.error("Got unexpected error while parsing INSERT message")
        Logger.error(raw_update: data)
        {:error, "Unexpected error"}
    end
  end
end

defimpl Core.Messages.MessageProtocol, for: PgSubscriber.Messages.Insert do
  alias Core.Messages.Insert

  def to_core_message(insert) do
    {:ok,
     %Insert{
       relation_oid: insert.relation_oid,
       columns: insert.columns
     }}
  end
end
