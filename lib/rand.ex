defmodule Rand do
  @doc """
  Creates an infinite sequence of random numbers in the
  unit interval (0, 1), which can then be used to perform
  rejection sampling, say.

  This returns a Stream of infinite values representing the
  sequence of random numbers starting at the initial seeded state.

  ## Examples
      iex> s = Seed.new(12345)
      iex> random_units = Rand.unit_gen(s)
      iex> random_units |> Enum.take(3)
      [0.6037224420217261, 0.5103925694443426, 0.17721060254528176]
  """
  def unit_gen(initial_state) do
    Stream.unfold(initial_state, fn sN -> :rand.uniform_s(sN) end)
  end

  @doc """
  Applies the function f to the infinite sequence of random
  numbers in the interval (0, 1). Useful for performing inverse
  transformations, for example, to obtain exponential random variables
  from uniform random variables.
  """
  def unit_gen_map(initial_state, f) do
    Stream.unfold(initial_state, fn sN ->
      {x, newstate} = :rand.uniform_s(sN)
      {f.(x), newstate}
    end)
  end
end
