defmodule Core.Messages.Update do
  @moduledoc """
  Represents UPDATE operation in the database replication stream.
  """
  alias Core.Messages.Column

  @type t :: %__MODULE__{
          table_name: bitstring(),
          columns: list(Column.t()),
          where: list(Column.t())
        }

  @enforce_keys [:table_name, :columns, :where]
  defstruct @enforce_keys
end
