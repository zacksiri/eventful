defmodule EventfulTest do
  use ExUnit.Case
  doctest Eventful

  test "greets the world" do
    assert Eventful.hello() == :world
  end
end
