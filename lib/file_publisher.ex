defmodule FilePublisher do
  @moduledoc """
  Documentation for `FilePublisher`.
  """
  alias Core.Messages.Delete
  alias Core.Messages.Update
  alias Core.Messages.Insert
  alias FilePublisher.Serializer

  use GenServer
  require Logger

  @behaviour Core.PublisherContract

  def start_link(file_path) do
    GenServer.start_link(__MODULE__, file_path)
  end

  @impl Core.PublisherContract
  def handle_message(server_pid, message) do
    GenServer.cast(server_pid, {:replication_message, message})
  end

  @impl true
  def init(file_path) do
    Registry.register(PublisherRegistry, :publishers, {FilePublisher, :handle_message})
    {:ok, file} = File.open(file_path, [:append])
    {:ok, %{file: file}}
  end

  @impl true
  def handle_cast({:replication_message, message}, state) do
    serialized = serialize(message)
    IO.write(state.file, serialized <> "\n")
    Logger.debug("Wrote message to file: #{inspect(message)}")
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, %{file: file}) do
    File.close(file)
    :ok
  end

  defp serialize(%message_type{} = message)
       when message_type in [Insert, Update, Delete] do
    Serializer.serialize(message)
  end

  defp serialize(message) do
    inspect(message)
  end
end
