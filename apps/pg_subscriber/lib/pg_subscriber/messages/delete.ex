defmodule PgSubscriber.Messages.Delete do
  @moduledoc """
  Helper module providing utility functions for handling of DELETE messages.
  """
  require Logger
  alias PgSubscriber.Column
  alias PgSubscriber.TupleData
  alias PgSubscriber.Messages.MessageBehaviour
  alias PgSubscriber.Utils

  @behaviour MessageBehaviour

  @type t :: %__MODULE__{
          relation_oid: Utils.oid(),
          tuple_type: ?O | ?K,
          columns: [Column.t()]
        }

  @enforce_keys [:relation_oid, :tuple_type, :columns]
  defstruct @enforce_keys

  @min_delete_bit_size 41

  @impl MessageBehaviour
  def from_data(data) when bit_size(data) < @min_delete_bit_size do
    Logger.error(
      "DELETE message data too small: expected at least #{@min_delete_bit_size} bits, got #{bit_size(data)}"
    )

    {:error, "DELETE message data too small"}
  end

  @impl MessageBehaviour
  def from_data(<<relation_oid::32, tuple_type::8, rest::binary>> = data) when rest !== <<>> do
    with {:ok, tuple_data, <<>>} <- TupleData.get_tuple_data(rest) do
      {:ok,
       %__MODULE__{
         relation_oid: relation_oid,
         tuple_type: <<tuple_type>>,
         columns: tuple_data.columns
       }}
    else
      {:error, reason} ->
        {:error, reason}

      _ ->
        Logger.error("Got unexpected error while parsing DELETE message")
        Logger.error(raw_update: data)
        {:error, "Unexpected error"}
    end
  end
end

defimpl Core.Messages.MessageProtocol, for: PgSubscriber.Messages.Delete do
  alias PgSubscriber.RelationStore
  alias Core.Messages.Delete, as: CoreDelete
  alias Core.Messages.Column, as: CoreColumn
  alias PgSubscriber.Messages.Delete, as: PgDelete

  def to_core_message(%PgDelete{
        relation_oid: relation_oid,
        columns: columns,
        tuple_type: _
      }) do
    with {:ok, relation} <- RelationStore.get_relation(relation_oid) do
      {:ok,
       %CoreDelete{
         relation_oid: relation_oid,
         where:
           Enum.zip(relation.columns, columns)
           |> Enum.filter(fn {col_meta, _} -> col_meta.in_primary_key end)
           |> Enum.map(fn {col_meta, col_data} ->
             %CoreColumn{name: col_meta.name, value: col_data.value}
           end)
       }}
    else
      {:error, nil} -> {:error, "Relation [#{relation_oid}] does not exist"}
    end
  end
end
