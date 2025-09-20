defmodule FilePublisherTest do
  alias Core.Messages.Insert
  use ExUnit.Case
  doctest FilePublisher

  test "receive INSERT message" do
    {:ok, pid} = FilePublisher.start_link("/tmp/replication.log")
    save_message(pid, 5)
    Process.sleep(100)
  end

  defp save_message(_pid, 0) do
  end

  defp save_message(pid, num) do
    message = %Insert{
      table_name: "#{num}",
      columns: [%{kind: 1, value: "Juraj"}]
    }

    FilePublisher.handle_message(pid, message)
    save_message(pid, num - 1)
  end
end
