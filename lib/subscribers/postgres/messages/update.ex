defmodule Subscribers.Postgres.Messages.Update do
  @moduledoc """
  Helper module providing utility functions for proper work with UPDATE messages.
  """
  alias Subscribers.Postgres.Messages.MessageBehaviour
  alias Subscribers.Postgres.Column
  alias Subscribers.Postgres.TupleData
  alias Subscribers.Postgres.Utils
  require Logger

  @behaviour MessageBehaviour

  @type t :: %__MODULE__{
          relation_oid: Utils.oid(),
          old_columns: list(Column.t()),
          new_columns: list(Column.t())
        }

  @enforce_keys [:relation_oid, :old_columns, :new_columns]
  defstruct @enforce_keys

  @min_update_bit_size 41

  @impl MessageBehaviour
  def from_data(data) when bit_size(data) < @min_update_bit_size do
    Logger.error(
      "UPDATE message data too small: expected at least #{@min_update_bit_size} bits, got #{bit_size(data)}"
    )

    {:error, "UPDATE message data too small"}
  end

  @impl MessageBehaviour
  def from_data(<<relation_oid::32, tuple_type::8, rest::binary>> = data)
      when rest != <<>> and tuple_type in [?O, ?K] do
    Logger.debug("Parsing Postgres UPDATE with O/K TupleData")

    with {:ok, old_data, rest} <- TupleData.get_tuple_data(rest),
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
        # TODO: potentially leaking sensitive data
        Logger.error(raw_update: data)
        {:error, "Unexpected error"}
    end
  end

  @impl MessageBehaviour
  def from_data(<<relation_oid::32, tuple_type::8, rest::binary>> = data)
      when rest != <<>> and tuple_type === ?N do
    Logger.debug("Parsing Postgres UPDATE without O/K TupleData")

    with {:ok, new_data, <<>>} <-
           TupleData.get_tuple_data(rest) do
      {:ok,
       %__MODULE__{
         relation_oid: relation_oid,
         old_columns: [],
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

defimpl Core.Messages.MessageProtocol, for: Subscribers.Postgres.Messages.Update do
  require Logger
  alias Core.Messages.Update
  alias Core.Messages.Column
  alias Subscribers.Postgres.RelationStore
  alias Subscribers.Postgres.Messages.Update, as: PgpUpdate

  def to_core_message(%PgpUpdate{
        relation_oid: relation_oid,
        old_columns: old_columns,
        new_columns: new_columns
      })
      when old_columns !== [] do
    Logger.debug("Converting PgUpdate with non-empty old_columns.")

    with {:ok, relation} <- RelationStore.get_relation(relation_oid) do
      {:ok,
       %Update{
         table_name: "#{relation.namespace}.#{relation.name}",
         columns:
           Enum.zip(new_columns, relation.columns)
           |> Enum.map(fn {new_col, rel_col} ->
             %Column{name: rel_col.name, value: new_col.value}
           end),
         where:
           Enum.zip(old_columns, relation.columns)
           |> Enum.map(fn {old_col, rel_col} ->
             %Column{name: rel_col.name, value: old_col.value}
           end)
       }}
    else
      {:error, nil} -> {:error, "Relation [#{relation_oid}] does not exist"}
    end
  end

  def to_core_message(%PgpUpdate{
        relation_oid: relation_oid,
        old_columns: old_columns,
        new_columns: new_columns
      })
      when old_columns === [] do
    Logger.debug("Converting PgUpdate with empty old_columns.")

    with {:ok, relation} <- RelationStore.get_relation(relation_oid) do
      {:ok,
       %Update{
         table_name: "#{relation.namespace}.#{relation.name}",
         columns:
           Enum.zip(new_columns, relation.columns)
           |> Enum.map(fn {new_col, rel_col} ->
             %Column{name: rel_col.name, value: new_col.value}
           end),
         where:
           Enum.zip(new_columns, relation.columns)
           |> Enum.filter(fn {_, column_meta} -> column_meta.in_primary_key end)
           |> Enum.map(fn {col_data, col_meta} ->
             %Column{name: col_meta.name, value: col_data.value}
           end)
       }}
    else
      {:error, nil} -> {:error, "Relation [#{relation_oid}] does not exist"}
    end
  end
end
