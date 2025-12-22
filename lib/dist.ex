defmodule Dist do
  @moduledoc """
  Public facing API for distributions.

  First, create a distribution `struct`. Then you can
  interrogate this distribution for some quantities.


  ```
    arrival_process |> Dists.rand_gen(seed)
                    |> Enum.take(10)
                    |> Stats.mean()
  ```
  ## Example

  You can define a distribution using the appropriate function and
  providing the associated parameters.

  Note that your parameters must make sense, otherwise they will
  produce errors.

    iex> _this_throws_an_error = Dist.exponential(-4)
    ** (ArgumentError) lambda must be nonnegative, provided: -4

  Obtaining the probability that x < 0.5 for an exponential distribution
  with lambda = 4.

    iex> exp4 = Dist.exponential(4)
    iex> exp4 |> Dist.cdf(0.5)
    0.8646647167633873

  Obtaining the density at x = 4 for a continuous uniform distribution
  over (0, 100)

    iex> cont = Dist.continuous_uniform(0, 100)
    iex> cont |> Dist.pdf(4)
    0.01
  """

  alias Internal.Dist.{ContinuousUniform, Exponential}

  @doc """
  Create a `struct` representing an exponential variable parametrized by lambda.

  Note: lambda is the _rate_. Other libraries provide an option to parametrize over
  the scale, which is equal to `1/lambda`. [Please refer to the entry on the exponential
  distribution for more information](https://en.wikipedia.org/wiki/Exponential_distribution).

  `lambda` must be nonnegative.

  ## Example

  Create exponential distribution with rate parameter = 4.

    iex> exp = Dist.exponential(4)
  """
  @spec exponential(number()) :: struct()
  def exponential(lambda) do
    unless lambda > 0 do
      raise ArgumentError, message: "lambda must be nonnegative, provided: #{inspect(lambda)}"
    end

    %Exponential{lambda: lambda}
  end

  @doc """
  Create a `struct` representing an exponential variable parametrized by `a`, `b`.

  By convention, `a` is the lower limit, and `b` is the upper limit.

  `a` must be less than `b`

  ## Example

  Create continuous uniform distribution with over the interval (0, 100).

    iex> exp = Dist.continuous_uniform(0, 100)
  """
  @spec continuous_uniform(number(), number()) :: struct()
  def continuous_uniform(a, b) do
    unless a < b do
      raise ArgumentError,
        message:
          "minimum value #{inspect(a)} must be smaller than the maximum value: #{inspect(b)}"
    end

    %ContinuousUniform{a: a, b: b}
  end

  @doc """
  Probability density function. Let `X` be a random variable. `pdf(x)` is defined
  as `P(X=x)`.

  `Sx` makes no distinction between continuous random variables and
  discrete random variables. Therefore, this function will work with
  both continuous and discrete random variables. However, it is important
  to note that if you pass in a non-integer value for a discrete random
  variable, you will get a probability of zero.

  ## Example
    iex> exp = Dist.exponential(4)
    iex> exp |> Dist.pdf(2)
    0.0013418505116100474
  """
  @spec pdf(struct(), number()) :: number()
  def pdf(dist, x) do
    case dist do
      %Exponential{lambda: lambda} ->
        Exponential.pdf(lambda, x)

      %ContinuousUniform{a: a, b: b} ->
        ContinuousUniform.pdf(a, b, x)
    end
  end

  @doc """
  Cumulative density function. Let `X` be a random variable. `pdf(x)` is defined
  as `P(X<=x)`.

  `Sx` makes no distinction between continuous random variables and
  discrete random variables. Therefore, this function will work with
  both continuous and discrete random variables. However, it is important
  to note that if you pass in a non-integer value for a discrete random
  variable, you will get a probability of zero.

  ## Example
    iex> exp = Dist.exponential(4)
    iex> exp |> Dist.pdf(2)
    0.0013418505116100474
  """
  @spec cdf(struct(), number()) :: number()
  def cdf(dist, x) do
    case dist do
      %Exponential{lambda: lambda} ->
        Exponential.cdf(lambda, x)

      %ContinuousUniform{a: a, b: b} ->
        ContinuousUniform.cdf(a, b, x)
    end
  end

  @doc """
  Inverse of the cumulative density function. Also known as the quantile function,
  the percent point function, or the percentile function.
  """
  @spec icdf(struct(), number()) :: number()
  def icdf(dist, p) do
    unless 0 <= p and p <= 1 do
      raise ArgumentError, message: "desired quantile must be between 0 and 1: #{inspect(p)}"
    end

    case dist do
      %Exponential{lambda: lambda} ->
        Exponential.icdf(lambda, p)

      %ContinuousUniform{a: a, b: b} ->
        ContinuousUniform.icdf(a, b, p)
    end
  end

  @doc """
  Actual mean of the distribution. Not to be confused
  with the sample mean that is defined in `Stat.mean`.
  """
  @spec mean(struct()) :: number()
  def mean(dist) do
    case dist do
      %Exponential{lambda: lambda} ->
        Exponential.mean(lambda)

      %ContinuousUniform{a: a, b: b} ->
        ContinuousUniform.mean(a, b)
    end
  end

  @doc """
  Actual variance of the distribution. Not to be confused
  with the sample mean that is defined in `Stat.mean`.
  """
  @spec variance(struct()) :: number()
  def variance(dist) do
    case dist do
      %Exponential{lambda: lambda} ->
        Exponential.variance(lambda)

      %ContinuousUniform{a: a, b: b} ->
        ContinuousUniform.variance(a, b)
    end
  end

  @doc """
  This returns a `Stream` with values drawn from the
  specified distribution.

  ## Examples

    iex> s = Seed.new(123456)
    iex> dist = Dist.continuous_uniform(0, 5)
    iex> dist
    ...> |> Dist.rand_gen(s)
    ...> |> Enum.take(5)
    [1.0444815097512206, 1.9519314546349142, 4.910320300405341, 2.925332258082625, 0.14647062067408068]

  """
  def rand_gen(dist, seed) do
    case dist do
      %Exponential{lambda: lambda} ->
        Exponential.rand_gen(lambda, seed)

      %ContinuousUniform{a: a, b: b} ->
        ContinuousUniform.rand_gen(a, b, seed)
    end
  end
end
