defmodule PgSubscriber.PgDumpParser do
  @moduledoc """
  Utility module providing functions parsing pg_dump output.
  """

  @doc """
  Filter INSERT statements from the pg_dump output.
  """
  def filter_inserts(pg_dump) do
  end

  @doc """
  Convert pg_dump INSERT statements to Core Insert messages.
  """
  def to_core_insert(pg_dump_inserts) do
  end
end
