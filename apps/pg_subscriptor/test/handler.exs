defmodule PgHandlerTest do
  use ExUnit.Case
  doctest PgHandler

  test "insert message" do
    # TODO: binary representation of columns
    message = <<"I", 1::32, "N", "%{id: 1, name: Juraj}"::binary>>
    assert GenServer.cast(PgHandler, {:handle, message}) == :ok

    # TODO: the test is used to see logger messages, but the app usually exits before the message is handled
    Process.sleep(100)
  end
end
