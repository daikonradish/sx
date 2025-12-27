defmodule Internal.Dist.Normal do
  defstruct [:mu, :sigma]

  @oneoversqrttwopi 0.398942280401432677939946059934
  @twopowsixteen 65536
  @twopowminussixteen 0.00001525878

  def pdf(mu, sigma, x) do
    case sigma == 0 do
      true ->
        raise ArgumentError,
          message: "Asking for the density of a normal distribution with zero variance."

      false ->
        xabs = abs((x - mu) / sigma)

        cond do
          xabs < 5.0 ->
            @oneoversqrttwopi * Math.exp(-0.5 * xabs * xabs) / sigma

          xabs > 38.56804 ->
            0.0

          true ->
            x1 = trunc(x * @twopowsixteen) * @twopowminussixteen
            x2 = xabs - x1

            @oneoversqrttwopi / sigma *
              (Math.exp(-0.5 * x1 * x1) * Math.exp((-0.5 * x2 - x1) * x2))
        end
    end
  end

  def cdf(mu, sigma, x) do
    case sigma == 0 do
      # the standard deviation is zero, so the random variable
      # always produces mu. Thus, the cdf is 0 for any value that
      # is less than mu, and 1 for any value that is mu or greater.
      true ->
        if x < 0, do: 0.0, else: 1.0

      false ->
        Math.cdf_standard_normal((x - mu) / sigma)
    end
  end

  def icdf(mu, sigma, p) do
    case sigma == 0 do
      true -> mu
      false -> mu + sigma * Math.inv_cdf_standard_normal(p)
    end
  end

  def rand_gen(mu, sigma, seed) do
    nil
  end

  def mean(mu, _) do
    mu
  end

  def variance(_, sigma) do
    sigma * sigma
  end
end
