defmodule DistContinuousUniformTest do
  alias Test.Support.DistHelper
  alias Test.Support.Helper
  use ExUnit.Case

  test "properties of random sample of continuous uniform" do
    asbs = [{0, 5.0}, {100, 200}, {402, 5020}]
    distributions = asbs |> Enum.map(fn {a, b} -> Dist.continuous_uniform(a, b) end)

    for dist <- distributions do
      assert DistHelper.has_correct_inverse_at_median(dist)

      assert Helper.percentage_error(
               DistHelper.mean_of_random_samples(dist, 50000),
               Dist.mean(dist)
             ) < 0.03

      assert Helper.percentage_error(
               DistHelper.variance_of_random_samples(dist, 50000),
               Dist.variance(dist)
             ) < 0.03
    end
  end

  test "continuous uniform over [0, 100]" do
    # Test for uniform(0, 100) just to make sure
    cont = Dist.continuous_uniform(0, 100)
    assert_in_delta(cont |> Dist.icdf(0.5), 50, 0.01)
    assert_in_delta(cont |> Dist.cdf(50), 0.5, 0.00001)
    assert_in_delta(cont |> Dist.pdf(1000), 0, 0.00001)
    assert_in_delta(cont |> Dist.pdf(10), 1 / 100, 0.00001)
  end
end
