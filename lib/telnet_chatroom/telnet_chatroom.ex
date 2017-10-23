require Logger

defmodule TelnetChatroom do
  alias TelnetChatroom.ClientRegistry

  def accept(port) do
    # The options below mean:
    #
    # 1. `:binary` - receives data as binaries (instead of lists)
    # 2. `packet: :line` - receives data line by line
    # 3. `active: false` - blockes on `:gen_tcp.recv/2` until data is available
    # 4. `reuseaddr: true` - allows us to reuse the address if the listener crashes
    #
    {:ok, socket} = :gen_tcp.listen(port,
                      [:binary, packet: :line, active: false, reuseaddr: true])
    Logger.info "Accepting connections on port #{port}"
    loop_acceptor(socket)
  end

  defp loop_acceptor(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    {ip_string, port} = get_ip_port(client)
    Logger.info "Connected to #{ip_string}:#{port}"
    ClientRegistry.put(client)
    {:ok, pid} = Task.Supervisor.start_child(TelnetChatroom.TaskSupervisor, 
        fn -> serve(client) end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp get_ip_port(client) do
    {:ok, {ip, port}} = :inet.peername(client)
    ip_string = ip |> Tuple.to_list |> Enum.join(".")
    {ip_string, port}    
  end

  defp serve(socket) do
    socket
    |> read_line()
    |> write_line()

    serve(socket)
  end

  defp read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> data
    end
  end

  defp write_line(line) do
    ClientRegistry.get_clients
    |> Enum.each(fn socket -> :gen_tcp.send(socket, line) end)
  end
end
