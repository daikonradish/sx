defmodule StatTest do
  use ExUnit.Case
  doctest Stat

  @x1 [0.5377, 1.8339, -2.2588, 0.8622, 0.3188]
  @x2 [-1.3077, -0.4336, 0.3426, 3.5784, 2.7694]
  @x3 [-1.3499, 3.0349, 0.7254, -0.0631, 0.7147]
  @x4 [-0.205, -0.1241, 1.4897, 1.409, 1.4172]

  test "computes mean correctly" do
    assert_in_delta(Stat.mean(@x1), 0.25876, 0.001)
    assert_in_delta(Stat.mean(@x2), 0.98982, 0.001)
    assert_in_delta(Stat.mean(@x3), 0.6124, 0.001)
    assert_in_delta(Stat.mean(@x4), 0.79736, 0.001)
  end

  test "computes variance correctly" do
    assert_in_delta(Stat.variance(@x1), 1.8529, 0.001)
    assert_in_delta(Stat.variance(@x2), 3.5183, 0.001)
    assert_in_delta(Stat.variance(@x3), 2.0397, 0.001)
    assert_in_delta(Stat.variance(@x4), 0.6183, 0.001)
  end

  test "computes skewness correctly" do
    assert_in_delta(Stat.skewness(@x1), -0.9362, 0.001)
    assert_in_delta(Stat.skewness(@x2), 0.2333, 0.001)
    assert_in_delta(Stat.skewness(@x3), 0.4363, 0.001)
    assert_in_delta(Stat.skewness(@x4), -0.4075, 0.001)
  end

  test "computes kurtosis correctly" do
    assert_in_delta(Stat.kurtosis(@x1), 2.706698, 0.001)
    assert_in_delta(Stat.kurtosis(@x2), 1.406896, 0.001)
    assert_in_delta(Stat.kurtosis(@x3), 2.37832, 0.001)
    assert_in_delta(Stat.kurtosis(@x4), 1.17596, 0.001)
  end

  test "computes geometric mean correctly" do
    assert_in_delta(Stat.geometric_mean([1.0, 2.0, 3.0, 4.0]), 2.21336, 0.001)

    assert_in_delta(
      Stat.geometric_mean([10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]),
      45.287286,
      0.001
    )
  end

  test "computes harmonic mean correctly" do
    assert_in_delta(
      Stat.harmonic_mean([1.0, 2.0, 3.0]),
      3.0 / (1.0 / 1.0 + 1.0 / 2.0 + 1.0 / 3.0),
      0.001
    )

    assert_in_delta(
      Stat.harmonic_mean([10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0]),
      34.141715,
      0.001
    )
  end

  test "computes generalized mean correctly" do
    assert_in_delta(
      Stat.generalized_mean([10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0], 3.5),
      69.1625879,
      0.001
    )

    assert_in_delta(
      Stat.generalized_mean([10.0, 20.0, 30.0, 40.0, 50.0, 60.0, 70.0, 80.0, 90.0, 100.0], -2.5),
      22.4655896,
      0.001
    )
  end

  test "computes median correctly" do
    # should also work with Ints
    assert Stat.median([1, 5, 6, 10, 12]) == 6
    assert Stat.median([1, 5, 6, 10, 11, 1203, 29384]) == 10
    assert Stat.median([1.0, 5.0, 8.0, 10.0, 12.0]) == 8.0
    assert Stat.median([1.0, 5.0, 8.0, 10.0, 12.0, 1.0, 5.0, 8.0, 10.0, 12.0]) == 8.0
    assert Stat.median([15.0, 1.0, 5.0, 8.0, 10.0, 12.0, 8.0, 10.0, 12.0, 15.0, 1.0, 5.0]) == 9.0
    assert Stat.median([10, 14, 19, 21, 22, 25, 27, 29, 30, 40, 1, 1, 89, 1, 100, 2, 400]) == 22
  end

  test "computes median absolute deviation correctly" do
    assert_in_delta(
      Stat.median_absolute_deviation([
        0.4691123,
        -0.28286334,
        -1.5090585,
        -1.13563237,
        1.21211203,
        -0.17321465,
        0.11920871,
        -1.04423597,
        -0.86184896,
        -2.10456922,
        -0.49492927,
        1.07180381,
        0.72155516,
        -0.70677113,
        -1.03957499,
        0.27185989,
        -0.42497233,
        0.56702035,
        0.27623202,
        -1.08740069,
        -0.67368971,
        0.11364841,
        -1.47842655,
        0.52498767,
        0.40470522,
        0.57704599,
        -1.71500202,
        -1.03926848,
        -0.37064686,
        -1.15789225,
        -1.34431181,
        0.84488514,
        1.07576978,
        -0.10904998,
        1.64356307,
        -1.46938796,
        0.35702056,
        -0.6746001,
        -1.77690372,
        -0.96891381,
        -1.29452359,
        0.41373811,
        0.27666171,
        -0.47203451,
        -0.01395975,
        -0.36254299,
        -0.00615357,
        -0.92306065,
        0.8957173,
        0.80524403,
        -1.20641178,
        2.56564595,
        1.43125599,
        1.34030885,
        -1.1702988,
        -0.22616928,
        0.41083451,
        0.81385029,
        0.13200317,
        -0.82731694,
        -0.07646702,
        -1.18767758,
        1.1301273,
        -1.43673732,
        -1.41368087,
        1.60792047,
        1.02418016,
        0.56960526,
        0.8759064,
        -2.21137223,
        0.97446607,
        -2.00674721,
        -0.41000057,
        -0.07863759,
        0.54595192,
        -1.21921682,
        -1.22682528,
        0.76980364,
        -1.28124731,
        -0.72770704,
        -0.12130623,
        -0.09788267,
        0.69577465,
        0.34173436,
        0.95972559,
        -1.1103361,
        -0.61997592,
        0.14974832,
        -0.73233937,
        0.68773839,
        0.17644434,
        0.40330952,
        -0.15495077,
        0.30162445,
        -2.17986061,
        -1.36984936,
        -0.95420784,
        1.46269605,
        -1.74316091,
        -0.82659092
      ]),
      0.8283261,
      0.0001
    )
  end
end
