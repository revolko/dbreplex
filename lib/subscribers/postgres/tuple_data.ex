defmodule Subscribers.Postgres.TupleData do
  alias __MODULE__
  alias Subscribers.Postgres.Column

  @type t :: %__MODULE__{
          num_of_cols: integer,
          columns: [Column.t()]
        }

  defstruct [:num_of_cols, :columns]

  @spec get_tuple_data(binary()) ::
          {:ok, TupleData.t(), binary()}
          | {:error, term()}
  @doc """
  Parses a TupleData binary message and returns the parsed TupleData struct and the remaining binary.
  In case of invalid format, an error with reason is returned.
  """
  def get_tuple_data(data) do
    with <<num_of_cols::16, rest::binary>> <- data,
         {:ok, columns, rest} <- Column.get_cols(num_of_cols, rest) do
      {:ok, %TupleData{num_of_cols: num_of_cols, columns: columns}, rest}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, {:invalid_data_length, data}}
    end
  end
end
