defmodule PgSubscriber.Messages.Delete do
  @moduledoc """
  Helper module providing utility functions for handling of DELETE messages.
  """
  alias PgSubscriber.Messages.Delete
  alias PgSubscriber.Column
  alias PgSubscriber.TupleData
  alias PgSubscriber.Messages.MessageBehaviour
  @behaviour MessageBehaviour

  @type t :: %__MODULE__{
          relation_oid: pos_integer(),
          tuple_type: ?O | ?K,
          columns: [Column.t()]
        }

  @enforce_keys [:relation_oid, :tuple_type, :columns]
  defstruct @enforce_keys

  @impl MessageBehaviour
  def from_data!(data) do
    <<relation_oid::32, tuple_type::8, rest::binary>> = data
    {:ok, tuple_data, <<>>} = TupleData.get_tuple_data(rest)

    %Delete{
      relation_oid: relation_oid,
      tuple_type: <<tuple_type>>,
      columns: tuple_data.columns
    }
  end
end

defimpl Core.Messages.MessageProtocol, for: PgSubscriber.Messages.Delete do
  alias Core.Messages.Delete, as: CoreDelete

  def to_core_message(delete) do
    %CoreDelete{
      relation_oid: delete.relation_oid,
      columns: delete.columns
    }
  end
end
