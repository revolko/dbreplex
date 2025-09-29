defmodule Publishers.Postgres.Publisher do
  use GenServer

  require Logger

  @behaviour Core.PublisherContract

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args)
  end

  @impl GenServer
  def init(init_args) do
    Registry.register(
      PublisherRegistry,
      :publishers,
      {Publishers.Postgres.Publisher, :handle_message}
    )

    {:ok, init_args}
  end

  @impl Core.PublisherContract
  def handle_message(server_pid, message) do
    Logger.debug("Postgres publisher handling message")
    Logger.debug(message: message)
    GenServer.cast(server_pid, {:replication_message, message})
  end

  @impl GenServer
  def handle_cast({:replication_message, message}, state) do
    Logger.info("Sending message to posgres", message: message)
    {:noreply, state}
  end
end
