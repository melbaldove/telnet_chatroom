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
    {:ok, pid} = Task.Supervisor.start_child(TelnetChatroom.TaskSupervisor, 
        fn -> 
          register_client(client)
          serve(client) 
        end)
    :ok = :gen_tcp.controlling_process(client, pid)
    loop_acceptor(socket)
  end

  defp get_ip_port(client) do
    {:ok, {ip, port}} = :inet.peername(client)
    ip_string = ip |> Tuple.to_list |> Enum.join(".")
    {ip_string, port}    
  end

  defp register_client(client) do
    :gen_tcp.send(client, "Register a name: ")
    name = read_line(client) |> String.trim("\r\n")
    ClientRegistry.put(client, name)
  end

  defp serve(socket) do
    name = ClientRegistry.get_name(socket)
    socket
    |> read_line()
    |> broadcast(name)

    serve(socket)
  end

  defp read_line(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, data} -> data
    end
  end

  defp broadcast(line, name) do
    ClientRegistry.get_clients
    |> Enum.each(fn socket -> :gen_tcp.send(socket, "#{name}: #{line}") end)
  end
end
