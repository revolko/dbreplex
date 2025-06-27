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
    <<_lsn_commit::64, rest::binary>> = body
    {name, _} = get_string(rest)
    Logger.info("Got postgres origin name #{name}")
  end

  defp handle_relation(body) do
    Logger.info("Got relation msg")
    # how to handle strings (null-terminated strings)
    <<_transaction_id::32, _relation_oid::32, rest::binary>> = body
    {namespace, rest} = get_string(rest)
    Logger.info("Got postgres relation namespace #{namespace}")
    {relation, _rest} = get_string(rest)
    Logger.info("Got postgres relation name #{relation}")
  end

  defp get_string(<<0>>) do
    {<<>>, <<>>}
  end

  defp get_string(<<0, rest::binary>>) do
    {<<>>, rest}
  end

  defp get_string(<<char::binary-size(1), rest::binary>>) do
    {last_char, new_rest} = get_string(rest)
    {char <> last_char, new_rest}
  end
end
