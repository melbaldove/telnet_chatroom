defmodule TelnetChatroomTest do
  use ExUnit.Case
  doctest TelnetChatroom

  test "greets the world" do
    assert TelnetChatroom.hello() == :world
  end
end
