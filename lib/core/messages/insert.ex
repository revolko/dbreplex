defmodule Core.Messages.Insert do
  @moduledoc """
  Represents an insert operation in the database replication stream.
  """

  @type t :: %__MODULE__{
          table_name: bitstring(),
          columns: map(),
          timestamp: DateTime.t() | nil
        }

  defstruct [
    :table_name,
    :columns,
    :timestamp
  ]
end
