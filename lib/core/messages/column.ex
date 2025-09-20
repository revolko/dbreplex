defmodule Core.Messages.Column do
  @moduledoc """
  Generic representation of Column
  """

  @type t() :: %__MODULE__{
          name: binary(),
          value: binary()
        }

  @enforce_keys [:name, :value]
  defstruct @enforce_keys
end
