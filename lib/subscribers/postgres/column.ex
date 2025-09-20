defmodule Subscribers.Postgres.Column do
  alias __MODULE__

  @type kind :: ?n | ?u | ?t | ?b
  @type col_val :: nil | binary | String.t()
  @type t :: %__MODULE__{
          kind: kind,
          value: col_val
        }

  defstruct [:kind, :value]

  @spec get_cols(non_neg_integer(), binary()) ::
          {:ok, [Column.t()], binary()}
          | {:error, term()}
  @doc """
  Parses all Columns from a single TupleData in a binary message and returns the parsed list of Column structs and the remaining binary.
  In case of invalid format, an error with reason is returned.
  """
  def get_cols(0, data) do
    {:ok, [], data}
  end

  def get_cols(num_of_cols, data) do
    with <<kind::8, rest_after_kind::binary>> <- data,
         {:ok, value, rest_after_parse_col} <- parse_column_from_binary(kind, rest_after_kind),
         {:ok, cols, rest_final} <- get_cols(num_of_cols - 1, rest_after_parse_col) do
      {:ok, [%Column{kind: kind, value: value} | cols], rest_final}
    else
      {:error, reason} -> {:error, reason}
      _ -> {:error, {:invalid_kind_length, data}}
    end
  end

  defp parse_column_from_binary(kind, data) do
    case kind do
      ?b ->
        parse_length_prefixed_value_from_binary(data, & &1)

      ?t ->
        parse_length_prefixed_value_from_binary(data, &to_string/1)

      col when col in [?n, ?u] ->
        {:ok, nil, data}

      _ ->
        {:error, {:unsupported_column_type, kind}}
    end
  end

  defp parse_length_prefixed_value_from_binary(data, processor) do
    case data do
      <<col_length::32, rest::binary>> ->
        case rest do
          <<value::binary-size(col_length), rest_after::binary>> ->
            {:ok, processor.(value), rest_after}

          _ ->
            {:error, {:incomplete_column_value, col_length, rest}}
        end

      _ ->
        {:error, {:invalid_column_length_prefix, data}}
    end
  end
end
