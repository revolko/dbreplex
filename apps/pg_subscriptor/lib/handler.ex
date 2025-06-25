defmodule PgHandler do
  require Logger

  def handle_message(message) do
    <<msg_type::utf8, msg::binary>> = message
    IO.puts(<<msg_type>>)
    IO.inspect(msg)
  end
end
