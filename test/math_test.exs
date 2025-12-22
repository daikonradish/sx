defmodule MathTest do
  use ExUnit.Case
  doctest Math

  test "n choose k" do
    assert Math.choose(25, 3) == 2300
    assert Math.choose(50, 8) == 536_878_650
    assert Math.choose(100, 0) == 1
    assert Math.choose(100, 100) == 1
  end
end
