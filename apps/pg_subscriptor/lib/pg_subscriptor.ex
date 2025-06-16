defmodule PgSubscriptor do
  use Task, restart: :permanent
  require Logger

  def start_link(port) do
    Task.start_link(__MODULE__, :accept, [port])
  end

  def accept(port) do
    {:ok, socket} = :gen_tcp.listen(port, [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info("Accepting connection on port #{port}")
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {:ok, pid} = Task.Supervisor.start_child(PgSubscriptor.TaskSupervisor, fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp serve(client) do
    client
    |> read_line()
    |> write_line(client)

    serve(client)
  end

  defp read_line(client) do
    :gen_tcp.recv(client, 0)
  end

  defp write_line({:ok, line}, client) do
    :gen_tcp.send(client, line)
  end

  defp write_line({:error, :closed}, _client) do
    Logger.info("Closing connection")
    exit(:shutdown)
  end
end
