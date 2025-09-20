defmodule Subscribers.Postgres.Utils do
  @moduledoc """
  Collection of PG helper functions.
  """
  @type pg_string :: binary()
  @type oid :: pos_integer()

  @doc """
  Parse null-terminated string from binary.
  Returns string and the rest of binary.
  """
  @spec get_string(binary) :: {pg_string, binary}
  def get_string(<<0>>) do
    {<<>>, <<>>}
  end

  def get_string(<<0, rest::binary>>) do
    {<<>>, rest}
  end

  def get_string(<<char::binary-size(1), rest::binary>>) do
    {last_char, new_rest} = get_string(rest)
    {char <> last_char, new_rest}
  end

  @doc """
  Parse column information from the Relation message.
  """
  @spec get_columns_info(binary) :: [
          {flags :: integer, name :: pg_string, type_oid :: integer, type_modifier :: integer}
        ]
  def get_columns_info(<<>>) do
    []
  end

  def get_columns_info(<<flags::8, msg::binary>>) do
    {name, rest} = get_string(msg)
    <<type_oid::32, type_modifier::32, rest::binary>> = rest
    [{flags, name, type_oid, type_modifier} | get_columns_info(rest)]
  end
end
