defmodule PgHandler do
  use GenServer
  require Logger

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  @impl true
  def handle_cast({:handle, message}, state) do
    handle_message(message)
    {:noreply, state}
  end

  defp handle_message(message) do
    <<msg_type::utf8, msg::binary>> = message

    case <<msg_type>> do
      "B" ->
        handle_beggin(msg)

      _ ->
        Logger.info("Got unknown msg")
    end
  end

  defp handle_beggin(body) do
    Logger.info("Got BEGGIN msg")
    <<_x_log_rec_ptr::64, _timestamp_tz::64, _transaction_id::32>> = body
  end
end
