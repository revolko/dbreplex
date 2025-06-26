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

      "M" ->
        handle_replication_msg(msg)

      "C" ->
        handle_commit(msg)

      "O" ->
        handle_origin(msg)

      "R" ->
        handle_relation(msg)

      _ ->
        Logger.info("Got unknown msg")
    end
  end

  defp handle_beggin(body) do
    Logger.info("Got BEGGIN msg")
    <<_x_log_rec_ptr::64, _timestamp_tz::64, _transaction_id::32>> = body
  end

  defp handle_replication_msg(_body) do
    Logger.info("Got PG replication msg")
  end

  defp handle_commit(body) do
    Logger.info("Got commit msg")
    <<_flag::8, _lsn_commit::64, _end_lsn_transaction::64, _timestamp_tz::64>> = body
  end

  defp handle_origin(body) do
    Logger.info("Got origin msg")
    <<_lsn_commit::64, _name>> = body
  end

  defp handle_relation(body) do
    Logger.info("Got relation msg")
    # how to handle strings (null-terminated strings)
    <<_transaction_id::32, _relation_oid::32, _namespace_and_rest::binary>> = body
  end
end
