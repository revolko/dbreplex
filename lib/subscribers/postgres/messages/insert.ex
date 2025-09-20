defmodule Subscribers.Postgres.Messages.Insert do
  @moduledoc """
  Represents Postgres INSERT operation in the database replication stream.
  """
  require Logger
  alias Subscribers.Postgres.Messages.MessageBehaviour
  alias Subscribers.Postgres.Column
  alias Subscribers.Postgres.Utils
  alias Subscribers.Postgres.TupleData

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

defimpl Core.Messages.MessageProtocol, for: Subscribers.Postgres.Messages.Insert do
  alias Subscribers.Postgres.RelationStore
  alias Core.Messages.Insert

  def to_core_message(insert) do
    with {:ok, relation} <- RelationStore.get_relation(insert.relation_oid) do
      {:ok,
       %Insert{
         table_name: "#{relation.namespace}.#{relation.name}",
         columns: insert.columns
       }}
    else
      {:error, nil} -> {:error, "Relation [#{insert.relation_oid}] does not exist"}
    end
  end
end
