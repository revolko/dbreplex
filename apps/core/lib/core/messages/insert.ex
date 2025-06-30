defmodule Core.Messages.Insert do
  @moduledoc """
  Represents an insert operation in the database replication stream.
  """

  @type t :: %__MODULE__{
          relation_oid: pos_integer(),
          columns: map(),
          timestamp: DateTime.t() | nil
        }

  defstruct [
    :relation_oid,
    :columns,
    :timestamp
  ]
end
