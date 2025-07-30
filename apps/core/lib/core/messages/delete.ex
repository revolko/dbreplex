defmodule Core.Messages.Delete do
  @moduledoc """
  Represents DELETE operation in the database replication stream.
  """

  @type t :: %__MODULE__{
          relation_oid: pos_integer(),
          where: list()
        }

  @enforce_keys [:relation_oid, :where]
  defstruct @enforce_keys
end
