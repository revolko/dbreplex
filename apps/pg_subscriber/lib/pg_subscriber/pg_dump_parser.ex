defmodule PgSubscriber.PgDumpParser do
  @moduledoc """
  Utility module providing functions for parsing pg_dump output.
  """
  alias Core.Messages.Insert

  @doc """
  Filter INSERT statements from the pg_dump output.
  """
  def filter_inserts(pg_dump) do
    filter_statement(pg_dump, "INSERT")
  end

  @doc """
  Convert pg_dump INSERT statements to Core Insert messages.
  """
  def to_core_insert(pg_dump_inserts) do
    Enum.map(pg_dump_inserts, fn raw_insert ->
      [[table_name, columns, values]] =
        Regex.scan(
          ~r/INSERT INTO ([^ ]+) \(([^\)]+)\) VALUES \(([^\)]+)\);/,
          raw_insert,
          capture: :all_but_first
        )

      %Insert{
        table_name: table_name,
        columns:
          Enum.zip_with(String.split(columns, ", "), pg_tuple_to_list(values), fn column_name,
                                                                                  value ->
            %{
              name: column_name,
              value: value
            }
          end),
        timestamp: ""
      }
    end)
  end

  defp filter_statement(pg_dump, statement_prefix) do
    lines = String.split(pg_dump, "\n")

    Enum.filter(lines, fn line ->
      hd(String.split(line, " ")) === statement_prefix
    end)
  end

  defp pg_tuple_to_list("") do
    []
  end

  defp pg_tuple_to_list(<<char, rest::binary>>) do
    case char do
      ?' ->
        part = "'" <> hd(String.split(rest, "'")) <> "'"
        {_, rest} = String.split_at(rest, String.length(part) + 1)
        [part | pg_tuple_to_list(rest)]

      _ ->
        part = <<char>> <> hd(String.split(rest, ","))
        {_, rest} = String.split_at(rest, String.length(part) + 1)
        [part | pg_tuple_to_list(rest)]
    end
  end
end
