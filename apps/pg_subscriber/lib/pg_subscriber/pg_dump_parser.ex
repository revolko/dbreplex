defmodule PgSubscriber.PgDumpParser do
  @moduledoc """
  Utility module providing functions for parsing pg_dump output.
  """
  require Logger
  alias Core.Messages.Insert

  @doc """
  Load pg_dump file, filter INSERTS and send them to Publishers.
  Expects file path (can be relative) as an input argument
  """
  def process_dump(pg_dump_path) do
    with {:ok, pg_dump} <- File.read(pg_dump_path) do
      pg_core_inserts = filter_inserts(pg_dump) |> to_core_insert()

      Enum.each(pg_core_inserts, fn core_insert ->
        Registry.dispatch(PublisherRegistry, :publishers, fn pubs ->
          for {pid, {module, handle_message}} <- pubs do
            apply(module, handle_message, [pid, core_insert])
          end
        end)
      end)
    else
      error ->
        Logger.error("Error while processing pg_dump file: #{pg_dump_path}")
        Logger.error(error: error)
        error
    end
  end

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
