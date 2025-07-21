defmodule PgSubscriber.ColumnMeta do
  @moduledoc """
  Struct containing metadata about Postgres columns.
  """

  @type t :: %__MODULE__{
          in_primary_key: boolean(),
          name: binary(),
          type_oid: pos_integer(),
          type_modifier: pos_integer()
        }

  @enforce_keys [:in_primary_key, :name, :type_oid, :type_modifier]
  defstruct @enforce_keys
end
