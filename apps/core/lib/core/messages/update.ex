defmodule Core.Messages.Update do
  @moduledoc """
  Represents UPDATE operation in the database replication stream.
  """
  alias Core.Messages.Column

  @type t :: %__MODULE__{
          relation_oid: pos_integer(),
          columns: list(Column.t()),
          where: list(Column.t())
        }

  @enforce_keys [:relation_oid, :columns, :where]
  defstruct @enforce_keys
end
