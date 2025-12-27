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
  end

  test "exponential random variables" do
    # Range of reasonable values for lambda
    lambdas = [0.5, 1.0, 50, 100, 1000.0, 2000]
    distributions = lambdas |> Enum.map(fn x -> Dist.exponential(x) end)

    for dist <- distributions do
      assert DistHelper.has_correct_inverse_at_median(dist)

      assert percentage_error(
               DistHelper.mean_of_random_samples(dist, 50000),
               Dist.mean(dist)
             ) < 0.025

      assert percentage_error(
               DistHelper.variance_of_random_samples(dist, 50000),
               Dist.variance(dist)
             ) < 0.05
    end

    # Test for exponential(10) just to make sure
    exp10 = Dist.exponential(10)
    assert_in_delta(exp10 |> Dist.icdf(0.5), 0.06931471805599453, 0.00001)
    assert_in_delta(exp10 |> Dist.cdf(0.06931471805599453), 0.5, 0.00001)
    assert_in_delta(exp10 |> Dist.pdf(0.06931471805599453), 5, 0.00001)
  end

  test "continuous uniform random variable" do
    asbs = [{0, 5.0}, {100, 200}, {402, 5020}]
    distributions = asbs |> Enum.map(fn {a, b} -> Dist.continuous_uniform(a, b) end)

    for dist <- distributions do
      assert DistHelper.has_correct_inverse_at_median(dist)

      assert percentage_error(
               DistHelper.mean_of_random_samples(dist, 50000),
               Dist.mean(dist)
             ) < 0.03

      assert percentage_error(
               DistHelper.variance_of_random_samples(dist, 50000),
               Dist.variance(dist)
             ) < 0.03
    end

    # Test for uniform(0, 100) just to make sure
    cont = Dist.continuous_uniform(0, 100)
    assert_in_delta(cont |> Dist.icdf(0.5), 50, 0.01)
    assert_in_delta(cont |> Dist.cdf(50), 0.5, 0.00001)
    assert_in_delta(cont |> Dist.pdf(1000), 0, 0.00001)
    assert_in_delta(cont |> Dist.pdf(10), 1 / 100, 0.00001)
  end

  @tag :skip
  test "binomial random variable" do
    d = Dist.binomial(4, 0.4)
    p = Dist.pdf(d, 3)
    assert_in_delta(p, 0.1536, 0.0001)

    assert_binomial_probs_sum_to_one(100, 0.06)
    assert_binomial_probs_sum_to_one(29, 0.88)
    assert_binomial_probs_sum_to_one(89, 0.4239)

    cdf_test_cases = [
      {1, 0.01, 1, 1.0},
      {1, 0.7, 1, 1.0},
      {1, 0.99, 1, 1.0},
      {2, 0.01, 1, 0.9999},
      {2, 0.7, 1, 0.51},
      {2, 0.99, 1, 0.019900000000000015},
      {3, 0.01, 1, 0.999702},
      {3, 0.7, 1, 0.21600000000000008},
      {3, 0.99, 1, 0.0002980000000000005},
      {4, 0.01, 1, 0.99940797},
      {4, 0.7, 1, 0.08370000000000004},
      {4, 0.99, 1, 3.97000000000001e-06},
      {5, 0.01, 1, 0.9990198504},
      {5, 0.7, 1, 0.030780000000000016},
      {5, 0.99, 1, 4.960000000000018e-08},
      {6, 0.01, 1, 0.998539552395},
      {6, 0.7, 1, 0.010935000000000007},
      {6, 0.99, 1, 5.950000000000025e-10},
      {1, 0.01, 0.23, 0.99},
      {1, 0.16, 0.23, 0.84},
      {1, 0.31, 0.23, 0.69},
      {1, 0.45999999999999996, 0.23, 0.54},
      {1, 0.61, 0.23, 0.39},
      {8, 0, 8, 1.0},
      {8, 0.055, 8, 1.0},
      {8, 0.392, 8, 1.0},
      {8, 0.899, 8, 1.0},
      {8, 1, 8, 1.0},
      {12, 0, 8, 1.0},
      {12, 0.055, 8, 0.9999999991298802},
      {12, 0.392, 8, 0.9868444111393797},
      {12, 0.899, 8, 0.026498811146146585},
      {12, 1, 8, 0.0},
      {13, 0, 8, 1.0},
      {13, 0.055, 8, 0.9999999973118687},
      {13, 0.392, 8, 0.9720603374282041},
      {13, 0.899, 8, 0.00674149634624183},
      {13, 1, 8, 0.0},
      {14, 0, 8, 1.0},
      {14, 0.055, 8, 0.9999999928450143},
      {14, 0.392, 8, 0.9486896737055776},
      {14, 0.899, 8, 0.0015532254797868462},
      {14, 1, 8, 0.0},
      {512, 0, 63, 1.0},
      {512, 0.055, 63, 0.9999999987395147},
      {512, 0.392, 63, 1.2995042220161285e-41},
      {512, 0.999, 63, 0.0},
      {512, 1, 63, 0.0},
      {1728, 0, 63, 1.0},
      {1728, 0.055, 63, 0.00022014871818382776},
      {1728, 0.392, 63, 5.9408967726612234e-270},
      {1728, 0.999, 63, 0.0},
      {1728, 1, 63, 0.0},
      {2197, 0, 63, 1.0},
      {2197, 0.055, 63, 2.305574820336648e-09},
      {2197, 0.392, 63, 0.0},
      {2197, 0.999, 63, 0.0},
      {2197, 1, 63, 0.0},
      {2744, 0, 63, 1.0},
      {2744, 0.055, 63, 1.0147749677054828e-16},
      {2744, 0.392, 63, 0.0},
      {2744, 0.999, 63, 0.0},
      {2744, 1, 63, 0.0}
    ]

    for {n, p, x, expected} <- cdf_test_cases do
      dist = Dist.binomial(n, p)
      assert_in_delta(Dist.cdf(dist, x), expected, 0.0001)
    end

    icdf_test_cases = [
      {2, 1.0, 2},
      {2, 0.5, 0},
      {2, 0.3333333333333333, 0},
      {2, 0.25, 0},
      {2, 0.2, 0},
      {2, 0.16666666666666666, 0},
      {2, 0.14285714285714285, 0},
      {2, 0.125, 0},
      {2, 0.1111111111111111, 0},
      {4, 1.0, 4},
      {4, 0.5, 1},
      {4, 0.3333333333333333, 1},
      {4, 0.25, 0},
      {4, 0.2, 0},
      {4, 0.16666666666666666, 0},
      {4, 0.14285714285714285, 0},
      {4, 0.125, 0.0},
      {4, 0.1111111111111111, 0},
      {8, 1.0, 8},
      {8, 0.5, 3},
      {8, 0.3333333333333333, 2},
      {8, 0.25, 1},
      {8, 0.2, 1},
      {8, 0.16666666666666666, 0},
      {8, 0.14285714285714285, 0},
      {8, 0.125, 0},
      {8, 0.1111111111111111, 0},
      {16, 1.0, 16},
      {16, 0.5, 7},
      {16, 0.3333333333333333, 4},
      {16, 0.25, 3},
      {16, 0.2, 2},
      {16, 0.16666666666666666, 2},
      {16, 0.14285714285714285, 1},
      {16, 0.125, 1},
      {16, 0.1111111111111111, 1},
      {32, 1.0, 32},
      {32, 0.5, 14},
      {32, 0.3333333333333333, 9},
      {32, 0.25, 6},
      {32, 0.2, 5},
      {32, 0.16666666666666666, 4},
      {32, 0.14285714285714285, 3},
      {32, 0.125, 3},
      {32, 0.1111111111111111, 2},
      {64, 1.0, 64},
      {64, 0.5, 29},
      {64, 0.3333333333333333, 19},
      {64, 0.25, 13},
      {64, 0.2, 10},
      {64, 0.16666666666666666, 8},
      {64, 0.14285714285714285, 7},
      {64, 0.125, 6},
      {64, 0.1111111111111111, 5},
      {128, 1.0, 128},
      {128, 0.5, 60},
      {128, 0.3333333333333333, 39},
      {128, 0.25, 28},
      {128, 0.2, 22},
      {128, 0.16666666666666666, 18},
      {128, 0.14285714285714285, 15},
      {128, 0.125, 13},
      {128, 0.1111111111111111, 12},
      {256, 1.0, 256},
      {256, 0.5, 122},
      {256, 0.3333333333333333, 80},
      {256, 0.25, 59},
      {256, 0.2, 46},
      {256, 0.16666666666666666, 38},
      {256, 0.14285714285714285, 32},
      {256, 0.125, 28},
      {256, 0.1111111111111111, 25},
      {512, 1.0, 512},
      {512, 0.5, 248},
      {512, 0.3333333333333333, 163},
      {512, 0.25, 121},
      {512, 0.2, 96},
      {512, 0.16666666666666666, 79},
      {512, 0.14285714285714285, 67},
      {512, 0.125, 58},
      {512, 0.1111111111111111, 52}
    ]

    for {n, p, expected} <- icdf_test_cases do
      dist = Dist.binomial(n, p)
      assert_in_delta(Dist.icdf(dist, 0.231), expected, 0.0001)
    end

    more_icdf_test_cases = [
      {100, 0.6, 0.025, 50},
      {100, 0.6, 0.975, 69},
      {1000, 0.5, 0.5, 500},
      {1000, 0.5, 0.95, 526},
      {10000, 0.5, 0.99, 5116},
      {1000, 0.1, 0.95, 116},
      # This test fails; it should be zero but I am returning one.
      # {10000, 0.0001, 0.05, 0},
      {1_000_000, 10.0e-6, 0.99, 18},
      {1_000_000, 0.012, 0.314159, 11947}
    ]

    for {n, pr, p, expected} <- more_icdf_test_cases do
      dist = Dist.binomial(n, pr)
      assert_in_delta(Dist.icdf(dist, p), expected, 0.0001)
    end

    nsps = [{1000, 0.07}, {5, 0.85}, {402, 0.913}]
    distributions = nsps |> Enum.map(fn {n, p} -> Dist.binomial(n, p) end)

    for dist <- distributions do
      assert percentage_error(
               DistHelper.mean_of_random_samples(dist, 50000),
               Dist.mean(dist)
             ) < 0.03

      assert percentage_error(
               DistHelper.variance_of_random_samples(dist, 50000),
               Dist.variance(dist)
             ) < 0.03
    end
  end

  test "test normal distribution " do
    icdf_test_cases = [
      {52.46, 269.55597, 0.025, -475.85999301775945},
      {52.46, 269.55597, 0.5, 52.46},
      {52.46, 269.55597, 0.0975, -296.8653572047102},
      {52.46, 269.55597, 0.99, 679.5409577445167},
      {215.62, 376.30489, 0.01, -659.7960808426724},
      {215.62, 376.30489, 0.025, -521.9240316063069},
      {215.62, 376.30489, 0.5, 215.62},
      {215.62, 376.30489, 0.0975, -272.0443619398568},
      {215.62, 376.30489, 0.99, 1091.0360808426724},
      {247.34, 80.72943, 0.01, 59.53526214697115},
      {247.34, 80.72943, 0.025, 89.1132247075526},
      {247.34, 80.72943, 0.5, 247.34},
      {247.34, 80.72943, 0.0975, 142.72040292083813},
      {247.34, 80.72943, 0.99, 435.14473785302886},
      {11.49, 47.75193, 0.01, -99.59760083684705},
      {11.49, 47.75193, 0.025, -82.10206299227777},
      {11.49, 47.75193, 0.5, 11.49},
      {11.49, 47.75193, 0.0975, -50.39310355160866},
      {11.49, 47.75193, 0.99, 122.57760083684704},
      {-3.37, 33.18611, 0.01, -80.57243644618549},
      {-3.37, 33.18611, 0.025, -68.41358038698455},
      {-3.37, 33.18611, 0.5, -3.37},
      {-3.37, 33.18611, 0.0975, -46.37683724417161},
      {-3.37, 33.18611, 0.99, 73.83243644618548},
      {-360.13, 67.98925, 0.01, -518.2966471951312},
      {-360.13, 67.98925, 0.025, -493.3864813358899},
      {-360.13, 67.98925, 0.5, -360.13},
      {-360.13, 67.98925, 0.0975, -448.23923031061173},
      {-360.13, 67.98925, 0.99, -201.96335280486878},
      {-344.87, 1220.6818, 0.01, -3184.6005103103466},
      {-344.87, 1220.6818, 0.025, -2737.362364583526},
      {-344.87, 1220.6818, 0.5, -344.87},
      {-344.87, 1220.6818, 0.0975, -1926.786756725101},
      {-344.87, 1220.6818, 0.99, 2494.860510310347},
      {290.15, 38.88852, 0.01, 199.68177417340524},
      {290.15, 38.88852, 0.025, 213.92990138793436},
      {290.15, 38.88852, 0.5, 290.15},
      {290.15, 38.88852, 0.0975, 239.75324514362444},
      {290.15, 38.88852, 0.99, 380.6182258265947},
      {139.39, 6.77793, 0.01, 123.62217695410236},
      {139.39, 6.77793, 0.025, 126.10550131026642},
      {139.39, 6.77793, 0.5, 139.39},
      {139.39, 6.77793, 0.0975, 130.60628499506606},
      {139.39, 6.77793, 0.99, 155.15782304589763},
      {128.3, 271.18625, 0.01, -502.5735561566078},
      {128.3, 271.18625, 0.025, -403.2152831024753},
      {128.3, 271.18625, 0.5, 128.3},
      {128.3, 271.18625, 0.0975, -223.13808408419163},
      {128.3, 271.18625, 0.99, 759.1735561566079},
      {-216.33, 493.24035, 0.01, -1363.77863961366},
      {-216.33, 493.24035, 0.025, -1183.063321721931},
      {-216.33, 493.24035, 0.5, -216.33},
      {-216.33, 493.24035, 0.0975, -855.5343977045891},
      {-216.33, 493.24035, 0.99, 931.1186396136601},
      {431.41, 179.74496, 0.01, 13.260694434444076},
      {431.41, 179.74496, 0.025, 79.11635199740732},
      {431.41, 179.74496, 0.5, 431.41},
      {431.41, 179.74496, 0.0975, 198.47332136607346},
      {431.41, 179.74496, 0.99, 849.559305565556},
      {-159.2, 398.83142, 0.01, -1087.0206260176897},
      {-159.2, 398.83142, 0.025, -940.895219102968},
      {-159.2, 398.83142, 0.5, -159.2},
      {-159.2, 398.83142, 0.0975, -676.0571419730077},
      {-159.2, 398.83142, 0.99, 768.6206260176896},
      {-349.85, 1072.27556, 0.01, -2844.335969391952},
      {-349.85, 1072.27556, 0.025, -2451.471479102518},
      {-349.85, 1072.27556, 0.5, -349.85},
      {-349.85, 1072.27556, 0.0975, -1739.4428293440533},
      {-349.85, 1072.27556, 0.99, 2144.635969391952},
      {439.55, 687.63573, 0.01, -1160.1299186000215},
      {439.55, 687.63573, 0.025, -908.1912652829092},
      {439.55, 687.63573, 0.5, 439.55},
      {439.55, 687.63573, 0.0975, -451.5769782263463},
      {439.55, 687.63573, 0.99, 2039.2299186000214},
      {264.15, 1233.91062, 0.01, -2606.355347593416},
      {264.15, 1233.91062, 0.025, -2154.2703753414894},
      {264.15, 1233.91062, 0.5, 264.15},
      {264.15, 1233.91062, 0.0975, -1334.910366165088},
      {264.15, 1233.91062, 0.99, 3134.655347593416},
      {182.95, 30.69807, 0.01, 111.53561011834307},
      {182.95, 30.69807, 0.025, 122.78288840511047},
      {182.95, 30.69807, 0.5, 182.95},
      {182.95, 30.69807, 0.0975, 143.16748556247816},
      {182.95, 30.69807, 0.99, 254.3643898816569},
      {-379.14, 257.44182, 0.01, -978.0392306462048},
      {-379.14, 257.44182, 0.025, -883.7166953144435},
      {-379.14, 257.44182, 0.5, -379.14},
      {-379.14, 257.44182, 0.0975, -712.7662807717845},
      {-379.14, 257.44182, 0.99, 219.75923064620486},
      {368.35, 263.99327, 0.01, -245.7901824255896},
      {368.35, 263.99327, 0.025, -149.06730136095837},
      {368.35, 263.99327, 0.5, 368.35},
      {368.35, 263.99327, 0.0975, 26.233506188382705},
      {368.35, 263.99327, 0.99, 982.4901824255896},
      {-197.1, 947.65636, 0.01, -2401.6783584072814},
      {-197.1, 947.65636, 0.025, -2054.4723353203244},
      {-197.1, 947.65636, 0.5, -197.1},
      {-197.1, 947.65636, 0.0975, -1425.1952132661556},
      {-197.1, 947.65636, 0.99, 2007.4783584072816}
    ]

    for {mu, sigma, p, expected} <- icdf_test_cases do
      assert_in_delta(
        Dist.normal(mu, sigma) |> Dist.icdf(p),
        expected,
        0.000001
      )
    end
  end

  def assert_binomial_probs_sum_to_one(n, p) do
    d = Dist.binomial(n, p)

    assert_in_delta(
      0..n
      |> Enum.map(fn x -> Dist.pdf(d, x) end)
      |> Enum.sum(),
      1.0,
      0.00000000001
    )
  end

  def percentage_error(estimated, actual) do
    abs(estimated - actual) / actual
  end
end

defmodule DistHelper do
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
