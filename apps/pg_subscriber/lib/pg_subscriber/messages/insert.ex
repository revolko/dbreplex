defmodule PgSubscriber.Messages.Insert do
  @moduledoc """
  Represents Postgres INSERT operation in the database replication stream.
  """
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
  def from_data!(data) do
    <<relation_oid::32, "N", rest::binary>> = data
    {:ok, new_data, <<>>} = TupleData.get_tuple_data(rest)

    %__MODULE__{
      relation_oid: relation_oid,
      columns: new_data.columns
    }
  end
end

defimpl Core.Messages.MessageProtocol, for: PgSubscriber.Messages.Insert do
  alias Core.Messages.Insert

  def to_core_message(insert) do
    %Insert{
      relation_oid: insert.relation_oid,
      columns: insert.columns
    }
  end
end
