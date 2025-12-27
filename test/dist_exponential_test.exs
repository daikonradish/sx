defmodule DistExponentialTest do
  alias Test.Support.DistHelper
  alias Test.Support.Helper
  use ExUnit.Case

  test "properties of random variable of exponential distribution" do
    # Range of reasonable values for lambda
    lambdas = [0.5, 1.0, 50, 100, 1000.0, 2000]
    distributions = lambdas |> Enum.map(fn x -> Dist.exponential(x) end)

    for dist <- distributions do
      assert DistHelper.has_correct_inverse_at_median(dist)

      assert Helper.percentage_error(
               DistHelper.mean_of_random_samples(dist, 50000),
               Dist.mean(dist)
             ) < 0.025

      assert Helper.percentage_error(
               DistHelper.variance_of_random_samples(dist, 50000),
               Dist.variance(dist)
             ) < 0.05
    end
  end

  test "exponential distribution with lambda 10" do
    # Test for exponential(10) just to make sure
    exp10 = Dist.exponential(10)
    assert_in_delta(exp10 |> Dist.icdf(0.5), 0.06931471805599453, 0.00001)
    assert_in_delta(exp10 |> Dist.cdf(0.06931471805599453), 0.5, 0.00001)
    assert_in_delta(exp10 |> Dist.pdf(0.06931471805599453), 5, 0.00001)
  end
end
