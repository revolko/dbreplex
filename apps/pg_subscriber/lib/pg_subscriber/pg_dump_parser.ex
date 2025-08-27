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
      # for now the relation oid is the name of the table (should change relation oid to the name)
      [[relation_oid, columns, values]] =
        Regex.scan(
          ~r/INSERT INTO ([^ ]+) \(([^\)]+)\) VALUES \(([^\)]+)\);/,
          raw_insert,
          capture: :all_but_first
        )

      %Insert{
        relation_oid: relation_oid,
        columns:
          Enum.zip_with(String.split(columns, ", "), String.split(values, ", "), fn column_name,
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
end
