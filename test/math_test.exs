defmodule MathTest do
  use ExUnit.Case
  doctest Math

  test "n choose k" do
    assert Math.choose(25, 3) == 2300
    assert Math.choose(50, 8) == 536_878_650
    assert Math.choose(100, 0) == 1
    assert Math.choose(100, 100) == 1
  end

  test "integer exponent" do
    assert Math.exponentiate_int(2, 2) == 4
    assert Math.exponentiate_int(2, 5) == 32
    assert Math.exponentiate_int(0.5, 10) == 0.0009765625
    assert_in_delta(Math.exponentiate_int(0.5, 100_000), 0.0, 0.00001)
  end

  test "loggamma" do
    assert_in_delta(Math.loggamma(12), 17.502307845873887, 0.001)
    assert_in_delta(Math.loggamma(12313), 103_652.10307512584, 0.001)
    assert_in_delta(Math.loggamma(0.3), 1.0957979948180754, 0.001)
    assert_in_delta(Math.loggamma(0.05), 2.968879201051731, 0.001)
  end

  test "factorial" do
    assert Math.factorial(10) == 3_628_800
  end

  test "inverse incomplete beta" do
    assert_in_delta(Math.inv_inc_beta(10, 10, 0.1), 0.00000, 0.001)
    assert_in_delta(Math.inv_inc_beta(10, 10, 0.3), 0.03255, 0.001)
    assert_in_delta(Math.inv_inc_beta(10, 10, 0.5), 0.50000, 0.001)
    assert_in_delta(Math.inv_inc_beta(10, 10, 0.7), 0.96744, 0.001)

    assert_in_delta(Math.inv_inc_beta(15, 10, 0.5), 0.15373, 0.001)
    assert_in_delta(Math.inv_inc_beta(15, 10, 0.6), 0.48908, 0.001)

    assert_in_delta(Math.inv_inc_beta(10, 15, 0.5), 0.84627, 0.001)
    assert_in_delta(Math.inv_inc_beta(10, 15, 0.6), 0.97834, 0.001)

    assert_in_delta(Math.inv_inc_beta(20, 20, 0.4), 0.10206, 0.001)
    assert_in_delta(Math.inv_inc_beta(40, 40, 0.4), 0.03581, 0.001)
    assert_in_delta(Math.inv_inc_beta(40, 40, 0.7), 0.9999, 0.001)
  end
end
