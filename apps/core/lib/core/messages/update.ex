defmodule Core.Messages.Update do
  @moduledoc """
  Represents UPDATE operation in the database replication stream.
  """

  @type t :: %__MODULE__{
          relation_oid: pos_integer(),
          columns: list()
        }

  @enforce_keys [:relation_oid, :columns]
  defstruct @enforce_keys
end
