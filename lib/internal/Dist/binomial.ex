defmodule Internal.Dist.Binomial do
  @moduledoc false
  defstruct [:n, :p]

  @spec pdf(non_neg_integer(), number(), non_neg_integer()) :: number()
  def pdf(n, p, k) do
    Math.choose(n, k) * Math.exponentiate_int(p, k) * Math.exponentiate_int(p, n - k)
  end

  def cdf(n, p, x) do
  end

  def icdf(n, p, x) do
  end

  def mean(n, p) do
    n * p
  end

  def variance(n, p) do
    n * p * (1 - p)
  end

  def rand_gen(n, p, seed) do
  end
end
