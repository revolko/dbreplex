defmodule PgSubscriber.Handler do
  use GenServer
  require Logger

  alias PgSubscriber.Messages.Insert, as: PgInsert
  alias PgSubscriber.RelationStore
  alias PgSubscriber.Messages.Relation, as: PgRelation
  alias PgSubscriber.Messages.Delete, as: PgDelete
  alias Core.Messages.MessageProtocol
  alias PgSubscriber.Messages.Update, as: PgUpdate

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  @impl true
  def handle_cast({:handle, message}, state) do
    case handle_message(message) do
      {:not_publish} ->
        Logger.info("Got information message. Not publishing.")

      {:publish, message} ->
        Logger.info("Got data message. Publishing.")

        Registry.dispatch(PublisherRegistry, :publishers, fn pubs ->
          for {pid, {module, handle_message}} <- pubs do
            apply(module, handle_message, [pid, message])
          end
        end)

      {:error, _} ->
        Logger.error("Error handling the message. Not publishing.")
    end

    {:noreply, state}
  end

  defp handle_message(message) do
    <<msg_type::utf8, msg::binary>> = message

    result =
      case <<msg_type>> do
        msg_type when msg_type in ["B", "M", "C", "O", "Y", "T"] ->
          Logger.info("Got unhandled message: #{msg_type}")
          {:not_publish}

        "R" ->
          Logger.info("Got RELATION msg")

          with {:ok, relation} <- PgRelation.from_data(msg) do
            RelationStore.store_relation(relation)
            {:not_publish}
          end

        "I" ->
          Logger.info("Got INSERT msg")
          {:publish, PgInsert}

        "U" ->
          Logger.info("Got UPDATE msg")
          {:publish, PgUpdate}

        "D" ->
          Logger.info("Got DELETE msg")
          {:publish, PgDelete}

        _ ->
          Logger.info("Got unknown msg: '#{<<msg_type>>}'")
          {:error, nil}
      end

    with {:publish, pg_msg_type} <- result,
         {:ok, pg_message} <- pg_msg_type.from_data(msg),
         {:ok, core_message} <- MessageProtocol.to_core_message(pg_message) do
      {:publish, core_message}
    end
  end
end
