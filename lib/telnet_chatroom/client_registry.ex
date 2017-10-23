defmodule TelnetChatroom.ClientRegistry do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def put(client) do
    Agent.update(__MODULE__, &([client | &1]))
  end

  def delete(client_list, client) do
    Agent.update(__MODULE__, &List.delete(&1, client))
  end

  def get_clients do
    Agent.get(__MODULE__, fn state -> state end)
  end
end