defmodule Math do
  require Integer

  alias Internal.Math.IncompleteBeta
  alias Internal.Math.InvIncompleteBeta
  alias Internal.Math.NormalCumulative
  alias Internal.Math.NormalPercentile
  alias Internal.Math.Log1p

  @spec sqrt(number) :: number()
  defdelegate sqrt(n), to: :math

  @spec pow(number, number) :: number()
  defdelegate pow(n, p), to: :math

  @spec log(number) :: number()
  defdelegate log(n), to: :math

  @spec exp(number) :: number()
  defdelegate exp(n), to: :math

  @spec factorial(integer()) :: integer()
  def factorial(n) do
    do_factorial(1, 1, n)
  end

  @spec expm1(number()) :: number()
  def expm1(x) do
    exp(x) - 1
  end

  @spec log1p(number()) :: number()
  def log1p(x) do
    Log1p.log1p(x)
  end

  defp do_factorial(acc, i, n) do
    case i > n do
      true -> acc
      false -> do_factorial(acc * i, i + 1, n)
    end
  end

  @doc """
  Uses the Lanczos approximation to compute the log gamma of
  the input.
  """
  @spec loggamma(number()) :: number()
  def loggamma(xx) do
    cofs = [
      {0, 57.1562356658629235},
      {1, -59.5979603554754912},
      {2, 14.1360979747417471},
      {3, -0.491913816097620199},
      {4, 0.339946499848118887e-4},
      {5, 0.465236289270485756e-4},
      {6, -0.983744753048795646e-4},
      {7, 0.158088703224912494e-3},
      {8, -0.210264441724104883e-3},
      {9, 0.217439618115212643e-3},
      {10, -0.164318106536763890e-3},
      {11, 0.844182239838527433e-4},
      {12, -0.261908384015814087e-4},
      {13, 0.368991826595316234e-5}
    ]

    # rational 671/128
    tmp1 = xx + 5.24218750000000000
    tmp = (xx + 0.5) * log(tmp1) - tmp1
    ser = 0.999999999999997092
    err = Enum.reduce(cofs, ser, fn {j, cofj}, acc -> acc + cofj / (xx + j + 1) end)
    tmp + Math.log(2.5066282746310005 * err / xx)
  end

  @doc """
  Note: beta(a, b) = gamma(a) * gamma(b) / gamma(a + b)
  """
  def logbeta(a, b) do
    loggamma(a) + loggamma(b) - loggamma(a + b)
  end

  @doc """
  Manual computation of a ^ b, where a is any real number but b is integral value,
  e.g. 0.4 ^ 29.
  """
  @spec exponentiate_int(number(), non_neg_integer()) :: number()
  def exponentiate_int(x, n) do
    case n <= 0 do
      true -> 1
      false -> x * exponentiate_int(x, n - 1)
    end
  end

  @doc """
  Computes the binomial coefficient, n choose k.
  """
  @spec choose(non_neg_integer(), non_neg_integer()) :: non_neg_integer()
  def choose(n, k) do
    cond do
      k > n ->
        raise ArgumentError,
          message:
            "k (you provided #{inspect(k)}) must be less than or equal to n (you provided #{inspect(n)})"

      k > div(n, 2) ->
        do_choose(1, 1, n, n - k)

      true ->
        do_choose(1, 1, n, k)
    end
  end

  defp do_choose(acc, i, n, k) do
    case i > k do
      true -> acc
      false -> do_choose(div((n - i + 1) * acc, i), i + 1, n, k)
    end
  end

  @doc """
  Inverse of the normal cdf.

  ## Examples
    iex> Math.inv_cdf_standard_normal(0.95) # z-score for 10%
    1.6448536269514715
    iex> Math.inv_cdf_standard_normal(0.975) # z-score for 5%
    1.9599639845400536
  """
  @spec inv_cdf_standard_normal(float()) :: float()
  def inv_cdf_standard_normal(p) do
    cond do
      p <= 0 and p >= 1 ->
        raise ArgumentError, message: "p must be between 0 and 1, you provided #{inspect(p)}"

      true ->
        NormalPercentile.ppnd16(p)
    end
  end

  def cdf_standard_normal(x) do
    NormalCumulative.pnorm(x)
  end

  def incomplete_beta(a, b, x) do
    IncompleteBeta.incomplete_beta(a, b, x)
  end

  def inv_incomplete_beta(a, b, p) do
    InvIncompleteBeta.inv_incomplete_beta(a, b, p)
  end
end
