defmodule Test.Support.DistHelper do
  @doc """
  Checks that the density at the median is close to the numerical derivative
  of the cumulative distribution. In other words:

  `{cdf(x + delta) - cdf(x - delta)} / delta/2 = pdf(x)` where x is icdf(0.5)

  Though this is a single unit test, it actually functions more like
  an integration test, since it checks three things at once:

    1. ppf (which is used to obtain the median value)
    2. pdf (used to obtain the density)
    3. cdf (used to obtain the numerical derivative)

  Note: this only works for when the pdf is very small (close to zero) or very
  large (say, 10^6). In this case division and multiplication may overflow or
  underflow. So it is best to choose from a distribution that doesn't have some weird
  properties like this.

  For example, the distribution for large values of lambda has extremly
  high skew and most of the values drawn from this distribution will be
  close to zero. E.g. exponential(5000) has 50th percentile at 0.00014. So the
  risk of


  https://github.com/scipy/scipy/blob/b1296b9b4393e251511fe8fdd3e58c22a1124899/scipy/stats/tests/test_continuous_basic.py#L643

  THIS WILL NOT WORK FOR DISCRETE DISTRIBUTIONS
  """
  def has_correct_inverse_at_median(dist) do
    tolerance = 0.01
    delta = 0.000001
    x_median = dist |> Dist.icdf(0.5)
    pdf_median = dist |> Dist.pdf(x_median)
    cdf_upper = dist |> Dist.cdf(x_median + delta)
    cdf_lower = dist |> Dist.cdf(x_median - delta)
    cdf_derivative = (cdf_upper - cdf_lower) / delta / 2.0
    abs(pdf_median - cdf_derivative) < tolerance
  end

  def mean_of_random_samples(dist, n) do
    # This test is not pure. Meaning that it relies on a random input
    # on each run. It is a stochastic test that is designed to catch obvious
    # flaws in the sampling strategy. It may fail with a small false positive
    # error rate. If it fails, rerun it again about 10 times. If there are
    # no further failures, the original failure was likely a false positive.
    random_state = Seed.random()

    dist
    |> Dist.rand_gen(random_state)
    |> Enum.take(n)
    |> Stat.mean()
  end

  def variance_of_random_samples(dist, n) do
    # This test is not pure. Meaning that it relies on a random input
    # on each run. It is a stochastic test that is designed to catch obvious
    # flaws in the sampling strategy. It may fail with a small false positive
    # error rate. If it fails, rerun it again about 10 times. If there are
    # no further failures, the original failure was likely a false positive.
    random_state = Seed.random()

    dist
    |> Dist.rand_gen(random_state)
    |> Enum.take(n)
    |> Stat.variance()
  end
end
