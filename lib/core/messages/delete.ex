defmodule Core.Messages.Delete do
  @moduledoc """
  Represents DELETE operation in the database replication stream.
  """
  alias Core.Messages.Column

  @type t :: %__MODULE__{
          table_name: bitstring(),
          where: [%Column{}]
        }

  @enforce_keys [:table_name, :where]
  defstruct @enforce_keys
end
