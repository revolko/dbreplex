defmodule DBReplexTest do
  alias Subscribers.Postgres.PgDumpParser
  use ExUnit.Case
  doctest DBReplex

  @file_publisher_target "/tmp/dbreplex-integration.txt"
  @expected_file_publisher_content "./test/assets/expected_file_publisher_content.txt"

  @tag integration: true
  test "Subscribers.Postgres to FilePublisher" do
    # initialization
    {:ok, file_publisher} =
      DynamicSupervisor.start_child(
        MainApp.DynamicSupervisor,
        {FilePublisher, [@file_publisher_target]}
      )

    {:ok, pg_subscriber} =
      DynamicSupervisor.start_child(
        MainApp.DynamicSupervisor,
        {Subscribers.Postgres,
         [
           repl: [
             host: "localhost",
             username: "postgres",
             database: "postgres",
             password: "postgres"
           ],
           handler: []
         ]}
      )

    [{_, pg_handler, _, _}] =
      Enum.filter(Supervisor.which_children(pg_subscriber), fn {module, pid, _, _} ->
        module == Subscribers.Postgres.Handler
      end)

    # test
    PgDumpParser.process_dump("./test/assets/pg_dump.sql")

    {:ok, pid} =
      Postgrex.start_link(
        hostname: "localhost",
        username: "postgres",
        password: "postgres",
        database: "postgres"
      )

    Postgrex.query!(pid, "INSERT INTO films (code, title) VALUES (10, 'name_film3')", [])

    # wait for process_dump and insert to finish
    :sys.get_state(pg_handler)
    :sys.get_state(file_publisher)

    {:ok, content} = File.read(@file_publisher_target)
    IO.inspect(content)
    {:ok, expected_content} = File.read(@expected_file_publisher_content)

    # cleanup
    :ok = File.rm(@file_publisher_target)

    # assert 
    assert(content === expected_content)
  end
end
