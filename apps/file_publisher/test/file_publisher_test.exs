defmodule FilePublisherTest do
  alias Core.Messages.Insert
  use ExUnit.Case
  doctest FilePublisher

  test "receive INSERT message" do
    {:ok, _pid} = FilePublisher.start_link("/tmp/replication.log")
    save_message(5)
    Process.sleep(1000)
  end

  defp save_message(0) do
  end

  defp save_message(num) do
    message = %Insert{
      relation_oid: num,
      columns: %{id: 1, name: "Juraj"}
    }

    FilePublisher.handle_message(message)
    save_message(num - 1)
  end
end
