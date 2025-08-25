defmodule PgSubscriber.PgDumpParserTest do
  use ExUnit.Case
  alias PgSubscriber.PgDumpParser
  alias Core.Messages.Insert
  doctest PgDumpParser

  setup_all do
    # current working dir is root of the app
    with {:ok, pg_dump} <- File.read("./test/assets/pg_dump.sql") do
      {:ok, pg_dump: pg_dump}
    end
  end

  test "filter insert", state do
    inserts = PgDumpParser.filter_inserts(state.pg_dump)
    assert(length(inserts) === 21)
  end

  test "convert to core many inserts", state do
    inserts = PgDumpParser.filter_inserts(state.pg_dump) |> PgDumpParser.to_core_insert()
    assert(length(inserts) === 21)

    assert(
      Enum.all?(inserts, fn %type{} = insert ->
        type === Insert
      end)
    )
  end

  test "convert to core insert" do
    [core_insert] =
      PgDumpParser.to_core_insert([
        "INSERT INTO test.table (did, name) VALUES (55, 'test value');"
      ])

    expected_insert = %Insert{
      relation_oid: "test.table",
      columns: [
        %{name: "did", value: "55"},
        %{name: "name", value: "'test value'"}
      ],
      timestamp: ""
    }

    assert(core_insert === expected_insert)
  end
end
