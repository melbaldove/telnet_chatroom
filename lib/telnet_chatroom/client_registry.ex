defmodule TelnetChatroom.ClientRegistry do
  use Agent

  def start_link(_opts) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def put(client, name) do
    Agent.update(__MODULE__, &Map.put(&1, client, name))
  end

  def get_name(client) do
    Agent.get(__MODULE__, &Map.get(&1, client))
  end

  def delete(client) do
    Agent.update(__MODULE__, &Map.delete(&1, client))
  end

  def get_clients do
    Agent.get(__MODULE__, &Map.keys(&1))
  end
end