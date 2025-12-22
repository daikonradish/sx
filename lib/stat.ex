defmodule Stat do
  @moduledoc """
  This module contains statistical functions designed to work with samples.
  Samples are simply a sequence of numerical values that are gathered from
  empirical observation. In `Sx`, these are represented as `[number]`.

  These statistical functions can
     - _summarize_: output a single `number` that describes the entire
       dataset, for example, `mean`, `variance`.
     - _transform_: transform the dataset according to some desired properties,
       such as `trim`-ming. Transformations can drop observations, changing
       the length of the dataset, or they can keep all observations, preserving the
       length of the dataset.
     - _discretize_: output a set of values that turn the samples into buckets that
       describe the empirical density, e.g. `histogram`.
  a given sample. A sample (also known as a dataset) is
  a list of measurements, represented by `[number]`.

  Functions that summarize or discretize will crash if they are provided with an
  empty list, as it is not clear what the user means when they pass in an empty list.
  """

  @doc """
  Computes the sample mean using a one-pass algorithm.

  This is efficient for extremely large datasets, as it goes over each item only
  once.

  ## Examples

      iex> Stat.mean([1, 2, 3, 4, 5])
      3.0
      iex> Stat.mean([1.0, 2.0, 3.0, 4.0 ,5.0])
      3.0
  """
  @spec mean(Enumerable.t(number)) :: float()
  def mean(sample) do
    {_, s1} =
      Enum.reduce(
        sample,
        {0.0, 0.0},
        fn x, {m0, m1} ->
          m0_new = m0 + 1.0
          {m0_new, m1 + (x - m1) / m0_new}
        end
      )

    s1
  end

  @doc """
  Computes the sample variance using Welford single-pass algorithm.

  This is efficient for extremely large datasets, as it goes over each item only
  once.
  ## Examples

      iex> Stat.variance([1, 2, 3, 4, 5])
      2.0
      iex> Stat.variance([1.0, 2.0, 3.0, 4.0 ,5.0])
      2.0
  """
  @spec variance(Enumerable.t(number)) :: float()
  def variance(sample) do
    {s0, _, s2} =
      Enum.reduce(
        sample,
        {0.0, 0.0, 0.0},
        fn x, {m0, m1, m2} ->
          m0_new = m0 + 1.0
          m1_new = m1 + (x - m1) / m0_new
          {m0_new, m1_new, m2 + (x - m1_new) * (x - m1)}
        end
      )

    s2 / s0
  end

  @doc """
  Computes the sample skewness using an extension to Welford's single-pass algorithm.

  This is efficient for extremely large datasets, as it goes over each item only
  once.
  ## Examples

      iex> Stat.skewness([1, 2, 3, 4, 5])
      0.0
      iex> Stat.skewness([1.0, 2.0, 3.0, 4.0 ,5.0])
      0.0
  """
  @spec skewness(Enumerable.t(number)) :: float()
  def skewness(sample) do
    {s0, _, s2, s3} =
      Enum.reduce(
        sample,
        {0.0, 0.0, 0.0, 0.0},
        fn x, {m0, m1, m2, m3} ->
          m0_new = m0 + 1.0
          delta = x - m1
          delta_n = delta / m0_new
          term1 = delta * delta_n * m0
          m3_new = m3 + term1 * delta_n * (m0 - 1) - 3 * delta_n * m2

          {m0_new, m1 + delta_n, m2 + term1, m3_new}
        end
      )

    sigma = Math.sqrt(s2)
    Math.sqrt(s0) * s3 / (sigma * sigma * sigma)
  end

  @doc """
  Computes the sample kurtosis using an extension to Welford's single-pass algorithm.

  This is efficient for extremely large datasets, as it goes over each item only
  once.

  Note: this is standard kurtosis, not Fisher kurtosis (also known
  as excess kurtosis). To compute excess kurtosis, subtract 3 from
  this result.
  ## Examples

      iex> Stat.kurtosis([1, 2, 3, 4, 5])
      1.7
      iex> Stat.kurtosis([1.0, 2.0, 3.0, 4.0 ,5.0])
      1.7
  """
  @spec kurtosis(Enumerable.t(number)) :: float()
  def kurtosis(sample) do
    {s0, _, s2, _, s4} =
      Enum.reduce(
        sample,
        {0.0, 0.0, 0.0, 0.0, 0.0},
        fn x, {m0, m1, m2, m3, m4} ->
          m0_new = m0 + 1.0
          delta = x - m1
          delta_n = delta / m0_new
          delta_n2 = delta_n * delta_n
          term1 = delta * delta_n * m0
          m3_new = m3 + term1 * delta_n * (m0 - 1) - 3 * delta_n * m2

          m4_new =
            m4 + term1 * delta_n2 * (m0_new * m0_new - 3 * m0_new + 3) + 6 * delta_n2 * m2 -
              4 * delta_n * m3

          {m0_new, m1 + delta_n, m2 + term1, m3_new, m4_new}
        end
      )

    s0 * s4 / (s2 * s2)
  end

  @doc """
  Computes the sample geometric mean using a one-pass algorithm.

  This is efficient for extremely large datasets, as it goes over each item only
  once.

  ## Examples

      iex> Stat.geometric_mean([1, 2, 3, 4, 5])
      2.605171084697352
      iex> Stat.geometric_mean([1.0, 2.0, 3.0, 4.0 ,5.0])
      2.605171084697352
  """
  @spec geometric_mean(Enumerable.t(number)) :: float()
  def geometric_mean(sample) do
    {_, s1} =
      Enum.reduce(
        sample,
        {0.0, 0.0},
        # x must be greater than zero.
        # should an error be thrown?
        fn x, {m0, m1} ->
          m0_new = m0 + 1.0
          {m0_new, m1 + (Math.log(x) - m1) / m0_new}
        end
      )

    Math.exp(s1)
  end

  @doc """
  Computes the sample geometric mean using a one-pass algorithm.

  This is efficient for extremely large datasets, as it goes over each item only
  once.

  ## Examples

      iex> Stat.harmonic_mean([1, 2, 3, 4, 5])
      2.18978102189781
      iex> Stat.harmonic_mean([1.0, 2.0, 3.0, 4.0 ,5.0])
      2.18978102189781
  """
  @spec harmonic_mean(Enumerable.t(number)) :: float()
  def harmonic_mean(sample) do
    {_, s1} =
      Enum.reduce(
        sample,
        {0.0, 0.0},
        # x must be greater than zero, or this value is not
        # really iterpretable.
        # should an error be thrown?
        fn x, {m0, m1} ->
          m0_new = m0 + 1.0
          {m0_new, m1 + (1 / x - m1) / m0_new}
        end
      )

    1 / s1
  end

  @doc """
  Computes the sample generalized mean using a one-pass algorithm. This mean is
  also known as the p-mean, power mean or the Hoelder mean.
  When p = 0, this returns the geometric mean.

  This is efficient for extremely large datasets, as it goes over each item only
  once.

  ## Examples

      iex> Stat.generalized_mean([1, 2, 3, 4, 5], 5.2)
      3.910174988435919
      iex> Stat.generalized_mean([1.0, 2.0, 3.0, 4.0 ,5.0], 0.5)
      2.810539823318741

  """
  @spec generalized_mean(Enumerable.t(number), float()) :: float()
  def generalized_mean(sample, 0), do: geometric_mean(sample)

  def generalized_mean(sample, p) do
    {_, s1} =
      Enum.reduce(
        sample,
        {0.0, 0.0},
        # x must be greater than or equal to zero
        # should an error be thrown?
        fn x, {m0, m1} ->
          m0_new = m0 + 1.0
          {m0_new, m1 + (Math.pow(x, p) - m1) / m0_new}
        end
      )

    Math.pow(s1, 1.0 / p)
  end

  @doc """
  Computes the median of a sample.

  This performs a sort (O (n log n)), and uses the length (O(n)).

  ## Examples

      iex> Stat.median([1, 2, 3, 4, 5])
      3
      iex> Stat.median([1.0, 2.0, 3.0, 4.0 ,5.0])
      3.0

  """
  @spec median(Enumerable.t(number)) :: float()
  def median(sample) do
    case sample do
      [x] ->
        x

      [x, y] ->
        (x + y) / 2

      [_, x, _] ->
        x

      [_, x, y, _] ->
        (x + y) / 2

      [_, _, x, _, _] ->
        x

      _ ->
        sorted = Enum.sort(sample)
        n = length(sample)

        if rem(n, 2) == 1 do
          [y] =
            sorted
            |> Enum.drop(div(n - 1, 2))
            |> Enum.take(1)

          y
        else
          [x, y] =
            sorted
            |> Enum.drop(div(n - 2, 2))
            |> Enum.take(2)

          (x + y) / 2
        end
    end
  end

  @doc """
  Computes the median absolute deviation.
  Though this measure of centrality is resistant to outliers, this
  will sort the list twice.

      iex> Stat.median_absolute_deviation([1, 2, 3, 4, 5])
      0
      iex> Stat.median_absolute_deviation([1.0, 2.0, 3.0, 4.0 ,5.0])
      0.0
  """

  @spec median_absolute_deviation(Enumerable.t(number)) :: float()
  def median_absolute_deviation(sample) do
    m = median(sample)
    median(Enum.map(sample, fn x -> abs(x - m) end))
  end

  ## TODO
  # quantiles
  # rank
  # IQR
  # winsorization
  # trimming
end
