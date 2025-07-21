defmodule PgSubscriber.Messages.Relation do
  @moduledoc """
  Helper module providing utility functions for handling of RELATION messages.
  """
  require Logger

  alias PgSubscriber.Messages.Relation
  alias PgSubscriber.Messages.MessageBehaviour
  alias PgSubscriber.Utils
  alias PgSubscriber.ColumnMeta

  @behaviour MessageBehaviour

  # Globals
  @primary_key_flag 1

  @type t :: %__MODULE__{
          relation_oid: Utils.oid(),
          namespace: binary(),
          name: binary(),
          replica_identity_setting: pos_integer(),
          columns: [ColumnMeta.t()]
        }

  @enforce_keys [:relation_oid, :namespace, :name, :replica_identity_setting, :columns]
  defstruct @enforce_keys

  def from_data!(data) do
    <<relation_oid::32, rest::binary>> = data
    {namespace, rest} = Utils.get_string(rest)
    {relation_name, rest} = Utils.get_string(rest)
    <<repl_identity_setting::8, _columns_num::16, rest::binary>> = rest

    columns =
      Enum.map(Utils.get_columns_info(rest), fn {flags, col_name, type_oid, type_modifier} ->
        %ColumnMeta{
          in_primary_key: Bitwise.band(flags, @primary_key_flag) == 1,
          name: col_name,
          type_oid: type_oid,
          type_modifier: type_modifier
        }
      end)

    %Relation{
      relation_oid: relation_oid,
      namespace: namespace,
      name: relation_name,
      replica_identity_setting: repl_identity_setting,
      columns: columns
    }
  end
end
