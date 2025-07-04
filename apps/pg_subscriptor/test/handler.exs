defmodule PgSubscriber.HandlerTest do
  use ExUnit.Case
  alias PgSubscriber.Handler
  doctest Handler

  test "insert message" do
    # TODO: binary representation of columns
    message = <<"I", 1::32, "N", "%{id: 1, name: Juraj}"::binary>>
    assert GenServer.cast(PgSubscriber.Handler, {:handle, message}) == :ok

    # TODO: the test is used to see logger messages, but the app usually exits before the message is handled
    Process.sleep(100)
  end
end
