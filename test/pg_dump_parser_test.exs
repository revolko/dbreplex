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
    assert(length(inserts) === 4)
  end

  test "convert to core many inserts", state do
    inserts = PgDumpParser.filter_inserts(state.pg_dump) |> PgDumpParser.to_core_insert()
    assert(length(inserts) === 4)

    assert(
      Enum.all?(inserts, fn %type{} = insert ->
        type === Insert
      end)
    )
  end

  test "convert to core insert" do
    inserts =
      PgDumpParser.to_core_insert([
        "INSERT INTO test.table (did, number, name, number2) VALUES (55, 123456, 'test value', 12431234);",
        "INSERT INTO test.table (did, number, name) VALUES ('55', 123456, 'test value');"
      ])

    expected_inserts = [
      %Insert{
        table_name: "test.table",
        columns: [
          %{name: "did", value: "55"},
          %{name: "number", value: "123456"},
          %{name: "name", value: "'test value'"},
          %{name: "number2", value: "12431234"}
        ],
        timestamp: ""
      },
      %Insert{
        table_name: "test.table",
        columns: [
          %{name: "did", value: "'55'"},
          %{name: "number", value: "123456"},
          %{name: "name", value: "'test value'"}
        ],
        timestamp: ""
      }
    ]

    assert(inserts === expected_inserts)
  end
end
