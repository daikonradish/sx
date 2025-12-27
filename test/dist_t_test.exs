defmodule DistTTest do
  use ExUnit.Case

  test "cdf of t distribution" do
    cdf_test_cases = [
      {1234.2, 0, 0.5},
      {134.2, 1.0, 0.84044489733301774859}
    ]

    for {df, x, expected} <- cdf_test_cases do
      assert_in_delta(
        Dist.t(df) |> Dist.cdf(x),
        expected,
        0.00000001
      )
    end
  end
end
