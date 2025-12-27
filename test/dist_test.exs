defmodule DistTest do
  use ExUnit.Case
  doctest Dist

  test "invalid parameters raise ArgumentError" do
    assert_raise(
      ArgumentError,
      fn -> Dist.exponential(-2304) end
    )

    assert_raise(
      ArgumentError,
      fn -> Dist.continuous_uniform(5, -12309) end
    )

    assert_raise(
      ArgumentError,
      fn -> Dist.normal(5, -23049.0) end
    )

    assert_raise(
      ArgumentError,
      fn -> Dist.t(-34) end
    )
  end
end
