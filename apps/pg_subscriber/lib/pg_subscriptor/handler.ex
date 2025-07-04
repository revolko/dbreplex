defmodule PgSubscriber.Handler do
  use GenServer
  require Logger

  alias Core.Messages.Insert
  alias PgSubscriber.TupleData

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

      "Y" ->
        handle_type(msg)

      "I" ->
        handle_insert(msg)

      "U" ->
        handle_update!(msg)

      "D" ->
        handle_delete!(msg)

      _ ->
        Logger.info("Got unknown msg: '#{<<msg_type>>}'")
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
    <<_relation_oid::32, rest::binary>> = body
    {namespace, rest} = get_string(rest)
    {relation, rest} = get_string(rest)
    <<_repl_identity_setting::8, _columns_num::16, rest::binary>> = rest

    Enum.each(get_columns_info(rest), fn {_flags, col_name, _type_oid, _type_modifier} ->
      Logger.info(
        "Got relation namespace: #{namespace}, relation: #{relation}, column: #{col_name}."
      )
    end)
  end

  defp handle_type(body) do
    Logger.info("Got TYPE msg")
    <<_transaction_id::32, _type_oid::32, rest::binary>> = body
    {_namespace, rest} = get_string(rest)
    {_type_name, _rest} = get_string(rest)
  end

  defp handle_insert(body) do
    Logger.info("Got INSERT msg")
    # transaction_id not present in this version
    <<relation_oid::32, "N", tuple_data::binary>> = body

    message = %Insert{
      relation_oid: relation_oid,
      columns: tuple_data
    }

    Logger.debug(message)
    message
  end

  defp handle_update!(body) do
    Logger.info("Got UPDATE msg")
    <<_relation_oid::32, rest::binary>> = body

    {tuple_type, tuple_data, rest} =
      case rest do
        <<tuple_type::8, rest::binary>> when tuple_type in [?O, ?K] ->
          Logger.info("Got #{<<tuple_type>>} tuple")
          {:ok, tuple_data, rest} = TupleData.get_tuple_data(rest)
          {tuple_type, tuple_data, rest}

        _ ->
          Logger.info("Not O/K tuple")
          {nil, nil, rest}
      end

    Logger.info(tuple_type: <<tuple_type>>)
    Logger.info(tuple_data: tuple_data)
    <<"N", rest::binary>> = rest
    {:ok, tuple_data, <<>>} = TupleData.get_tuple_data(rest)
    Logger.info(tuple_type: "N")
    Logger.info(tuple_data: tuple_data)
  end

  defp handle_delete!(body) do
    Logger.info("Got DELETE msg")
    <<_relation_oid::32, tuple_type::8, rest::binary>> = body
    {:ok, tuple_data, <<>>} = TupleData.get_tuple_data(rest)

    Logger.info(tuple_type: <<tuple_type>>)
    Logger.info(tuple_data: tuple_data)
  end

  defp get_columns_info(<<>>) do
    []
  end

  defp get_columns_info(<<flags::8, msg::binary>>) do
    {name, rest} = get_string(msg)
    <<type_oid::32, type_modifier::32, rest::binary>> = rest
    [{flags, name, type_oid, type_modifier} | get_columns_info(rest)]
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
