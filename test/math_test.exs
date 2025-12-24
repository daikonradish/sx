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

  test "incomplete beta" do
    assert_in_delta(Math.inc_beta(10, 10, 0.1), 0.00000, 0.001)
    assert_in_delta(Math.inc_beta(10, 10, 0.3), 0.03255, 0.001)
    assert_in_delta(Math.inc_beta(10, 10, 0.5), 0.50000, 0.001)
    assert_in_delta(Math.inc_beta(10, 10, 0.7), 0.96744, 0.001)

    assert_in_delta(Math.inc_beta(15, 10, 0.5), 0.15373, 0.001)
    assert_in_delta(Math.inc_beta(15, 10, 0.6), 0.48908, 0.001)

    assert_in_delta(Math.inc_beta(10, 15, 0.5), 0.84627, 0.001)
    assert_in_delta(Math.inc_beta(10, 15, 0.6), 0.97834, 0.001)

    assert_in_delta(Math.inc_beta(20, 20, 0.4), 0.10206, 0.001)
    assert_in_delta(Math.inc_beta(40, 40, 0.4), 0.03581, 0.001)
    assert_in_delta(Math.inc_beta(40, 40, 0.7), 0.9999, 0.001)
  end

  test "inverse incomplete beta" do
    test_cases = [
      # Edge cases
      {1.0, 1.0, 0.0, 0.0, "Edge: p=0"},
      {1.0, 1.0, 1.0, 1.0, "Edge: p=1"},
      {2.0, 3.0, 0.0, 0.0, "Edge: p=0 with non-uniform"},
      {2.0, 3.0, 1.0, 1.0, "Edge: p=1 with non-uniform"},

      # Uniform distribution {a=1, b=1}
      {1.0, 1.0, 0.25, 0.25, "Uniform: p=0.25"},
      {1.0, 1.0, 0.5, 0.5, "Uniform: p=0.5"},
      {1.0, 1.0, 0.75, 0.75, "Uniform: p=0.75"},

      # Symmetric cases {a=b}
      {2.0, 2.0, 0.5, 0.5, "Symmetric: a=b=2, median"},
      {3.0, 3.0, 0.5, 0.5, "Symmetric: a=b=3, median"},
      {5.0, 5.0, 0.5, 0.5, "Symmetric: a=b=5, median"},
      {2.0, 2.0, 0.25, 0.3263518223330697, "Symmetric: a=b=2, lower quartile"},
      {2.0, 2.0, 0.75, 0.6736481776669303, "Symmetric: a=b=2, upper quartile"},

      # Small a, moderate b {left-skewed}
      {0.5, 2.0, 0.1, 0.004457681887621376, "Small a: a=0.5, b=2"},
      {0.5, 2.0, 0.5, 0.12061475842818319, "Small a: a=0.5, b=2, median"},
      {0.5, 5.0, 0.5, 0.0466872453369664, "Small a: a=0.5, b=5, median"},
      {1.0, 3.0, 0.5, 0.20629947401590035, "Small a: a=1, b=3, median"},

      # Moderate a, small b {right-skewed}
      {2.0, 0.5, 0.5, 0.8793852415718169, "Small b: a=2, b=0.5, median"},
      {3.0, 1.0, 0.5, 0.7937005259840997, "Small b: a=3, b=1, median"},
      {5.0, 0.5, 0.5, 0.9533127546630336, "Small b: a=5, b=0.5, median"},

      # Both parameters small {U-shaped}
      {0.5, 0.5, 0.1, 0.024471741852423214, "U-shaped: a=b=0.5, p=0.1"},
      {0.5, 0.5, 0.5, 0.4999999999999999, "U-shaped: a=b=0.5, median"},
      {0.5, 0.5, 0.9, 0.9755282581475768, "U-shaped: a=b=0.5, p=0.9"},
      {0.3, 0.7, 0.5, 0.15877468697850153, "U-shaped: a=0.3, b=0.7"},

      # Both parameters large {concentrated}
      {10.0, 10.0, 0.5, 0.5, "Large params: a=b=10, median"},
      {20.0, 20.0, 0.5, 0.49999999999999994, "Large params: a=b=20, median"},
      {10.0, 30.0, 0.5, 0.24580106752001296, "Large params: a=10, b=30"},
      {50.0, 50.0, 0.1, 0.43602641907249107, "Large params: a=b=50, p=0.1"},
      {50.0, 50.0, 0.9, 0.563973580927509, "Large params: a=b=50, p=0.9"},

      # One large, one small
      {0.5, 10.0, 0.5, 0.023051418325296138, "Mixed: a=0.5, b=10"},
      {10.0, 0.5, 0.5, 0.9769485816747039, "Mixed: a=10, b=0.5"},
      {1.0, 10.0, 0.5, 0.06696700846319262, "Mixed: a=1, b=10"},
      {10.0, 1.0, 0.5, 0.9330329915368074, "Mixed: a=10, b=1"},

      # Extreme tails {testing numerical precision}
      {2.0, 2.0, 0.01, 0.058903135778195254, "Extreme tail: p=0.01"},
      {2.0, 2.0, 0.99, 0.9410968642218047, "Extreme tail: p=0.99"},
      {5.0, 5.0, 0.001, 0.10252344780625376, "Extreme tail: p=0.001"},
      {5.0, 5.0, 0.999, 0.8974765521937462, "Extreme tail: p=0.999"},
      {10.0, 10.0, 0.0001, 0.14385151398467935, "Very extreme: p=0.0001"},
      {10.0, 10.0, 0.9999, 0.8561484860153225, "Very extreme: p=0.9999"},

      # Asymmetric cases
      {2.0, 5.0, 0.3, 0.18180347131894917, "Asymmetric: a=2, b=5"},
      {2.0, 5.0, 0.7, 0.36035769038002013, "Asymmetric: a=2, b=5"},
      {5.0, 2.0, 0.3, 0.6396423096199798, "Asymmetric: a=5, b=2"},
      {3.0, 7.0, 0.5, 0.28623666802278286, "Asymmetric: a=3, b=7"},

      # Integer-like parameters {common in Bayesian applications}
      {3.0, 8.0, 0.5, 0.25857472328496317, "Bayesian-like: a=3, b=8"},
      {15.0, 5.0, 0.5, 0.7584574497236709, "Bayesian-like: a=15, b=5"},
      {100.0, 200.0, 0.5, 0.3329625066484857, "Large Bayesian: a=100, b=200"},

      # Very asymmetric
      {1.0, 20.0, 0.5, 0.03406367107515447, "Very asymmetric: a=1, b=20"},
      {20.0, 1.0, 0.5, 0.9659363289248455, "Very asymmetric: a=20, b=1"},
      {0.1, 10.0, 0.5, 6.210520703091691e-05, "Extreme asymmetric: a=0.1, b=10"},

      # Additional challenging cases
      {0.2, 0.8, 0.5, 0.04329908929545435, "Both small, asymmetric"},
      {100.0, 100.0, 0.5, 0.5, "Very large symmetric"},
      {1.5, 3.5, 0.25, 0.14991308950571583, "Non-integer moderate"},
      {7.5, 2.5, 0.75, 0.8497421060839618, "Non-integer asymmetric"}
    ]

    for {a, b, p, expected, _description} <- test_cases do
      assert_in_delta(Math.inv_inc_beta(a, b, p), expected, 0.0001)
    end
  end
end
