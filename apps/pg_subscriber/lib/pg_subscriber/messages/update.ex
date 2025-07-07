defmodule PgSubscriber.Messages.Update do
  @moduledoc """
  Helper module providing utility functions for proper work with UPDATE messages.
  """
  alias PgSubscriber.Messages.MessageBehaviour
  alias PgSubscriber.Column
  alias PgSubscriber.TupleData
  alias PgSubscriber.Messages.Update
  require Logger

  @behaviour MessageBehaviour

  @type t :: %__MODULE__{
          relation_oid: pos_integer(),
          old_columns: list(Column.t()),
          new_columns: list(Column.t())
        }

  @enforce_keys [:relation_oid, :old_columns, :new_columns]
  defstruct @enforce_keys

  def from_data!(data) do
    <<relation_oid::32, rest::binary>> = data

    {_tuple_type, old_data, rest} =
      case rest do
        <<tuple_type::8, rest::binary>> when tuple_type in [?O, ?K] ->
          Logger.info("Got #{<<tuple_type>>} tuple")
          {:ok, tuple_data, rest} = TupleData.get_tuple_data(rest)
          {tuple_type, tuple_data, rest}

        _ ->
          Logger.info("Not O/K tuple")
          {nil, nil, rest}
      end

    <<"N", rest::binary>> = rest
    {:ok, new_data, <<>>} = TupleData.get_tuple_data(rest)

    %Update{
      relation_oid: relation_oid,
      # TODO: convert TupleData struct to some generic representation of data
      old_columns: old_data.columns,
      # TODO: convert TupleData struct to some generic representation of data
      new_columns: new_data.columns
    }
  end
end

defimpl Core.Messages.MessageProtocol, for: PgSubscriber.Messages.Update do
  alias Core.Messages.Update

  def to_core_message(update_message) do
    %Update{
      relation_oid: update_message.relation_oid,
      columns: update_message.new_columns
    }
  end
end
