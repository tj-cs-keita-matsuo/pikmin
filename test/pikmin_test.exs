defmodule PikminTest do
  use ExUnit.Case
  doctest Pikmin

  test "greets the world" do
    assert Pikmin.hello() == :world
  end
end
