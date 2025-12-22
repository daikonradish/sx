defmodule Seed do
  @moduledoc """
  Sx is opinionated about random number generation. Simulation is a core
  functionality of statistics libraries. A core problem with debugging
  simulations is not being able to draw the line between the random and
  the deterministic, which makes reproduceability hard. Debugging such
  simulations becomes much harder.

  Sx makes it clear that each "random" run depends on the starting seed.

  If you truly do not care about reproduceability, call `Seed.random()` instead.

  Note: Sx is not opinionated about the underlying pseudorandom number generation
  algorithm. Currently, we use the default `exsss` algorithm, XORSHIFT116.
  This is good enough for statistical purposes. However, the internal
  implementation is subject to change later. If it is important to you
  to use other PRNG algorithms, you can simply create your own new seed
  with `:rand.seed_s(<ALGORITHM>, <INTEGER VALUE>)`
  """

  @doc """
  Provides a new seed, to be used whenever pseudorandomness is required
  for simulating random processes, but reproduceability across runs
  of the random process are required.

  Note that Erlang's return typing for `rand:seed_s` is quite complex,
  shall we say, which is why I skip the spec here. If you are reading
  this and you understand how to write the spec, please open a PR!
  ## Examples
      iex > s = Seed.new(12345)
  """
  def new(i) do
    :rand.seed_s(:exsss, i)
  end

  @doc """
  Provides a random seed. Used whenever the developer does not
  care about reproduceability. Uses Erlang's internal process state
  to randomize along with certain system internals like clocktime.

  ## Examples
      iex > s = Seed.random()
  """
  def random() do
    :rand.seed_s(:exsss)
  end
end
