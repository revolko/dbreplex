defmodule PgSubscriber.Messages.Update do
  @moduledoc """
  Helper module providing utility functions for proper work with UPDATE messages.
  """
  alias PgSubscriber.Messages.MessageBehaviour
  alias PgSubscriber.Column
  alias PgSubscriber.TupleData
  alias PgSubscriber.Utils
  require Logger

  @behaviour MessageBehaviour

  @type t :: %__MODULE__{
          relation_oid: Utils.oid(),
          old_columns: list(Column.t()),
          new_columns: list(Column.t())
        }

  @enforce_keys [:relation_oid, :old_columns, :new_columns]
  defstruct @enforce_keys

  @impl MessageBehaviour
  def from_data(data) do
    with <<relation_oid::32, rest::binary>> <- data,
         <<_tuple_type::8, rest::binary>> <- rest,
         {:ok, old_data, rest} <- TupleData.get_tuple_data(rest),
         <<"N", rest::binary>> <- rest,
         {:ok, new_data, <<>>} <-
           TupleData.get_tuple_data(rest) do
      {:ok,
       %__MODULE__{
         relation_oid: relation_oid,
         old_columns: old_data.columns,
         new_columns: new_data.columns
       }}
    else
      {:error, reason} ->
        {:error, reason}

      _ ->
        Logger.error("Got unexpected error while parsing UPDATE message")
        Logger.error(raw_update: data)
        {:error, "Unexpected error"}
    end
  end
end

defimpl Core.Messages.MessageProtocol, for: PgSubscriber.Messages.Update do
  alias Core.Messages.Update
  alias Core.Messages.Column
  alias PgSubscriber.RelationStore

  def to_core_message(update_message) do
    with {:ok, relation} <- RelationStore.get_relation(update_message.relation_oid) do
      {:ok,
       %Update{
         relation_oid: update_message.relation_oid,
         columns:
           Enum.zip(update_message.new_columns, relation.columns)
           |> Enum.map(fn {new_col, rel_col} ->
             %Column{name: rel_col.name, value: new_col.value}
           end),
         where:
           Enum.zip(update_message.old_columns, relation.columns)
           |> Enum.map(fn {old_col, rel_col} ->
             %Column{name: rel_col.name, value: old_col.value}
           end)
       }}
    else
      {:error, nil} -> {:error, "Relation [#{update_message.relation_oid}] does not exists"}
    end
  end
end
