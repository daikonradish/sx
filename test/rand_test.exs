defmodule RandTest do
  use ExUnit.Case
  doctest Rand

  test "same seed, same result" do
    # any random number will do.
    # It's preferable to use any random number
    # as this should hold for _ALL_ seeds.
    s = :rand.uniform(9_043_825_890)
    s1 = Seed.new(s)
    s2 = Seed.new(s)

    seq1 = Rand.unit_gen(s1) |> Enum.take(50)
    seq2 = Rand.unit_gen(s2) |> Enum.take(50)

    assert seq1 == seq2
  end
end
