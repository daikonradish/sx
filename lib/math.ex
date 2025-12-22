defmodule Math do
  require Integer

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

  defp do_factorial(acc, i, n) do
    case i > n do
      true -> acc
      false -> do_factorial(acc * i, i + 1, n)
    end
  end

  @doc """
  Uses the Lanczos approximation to compute the log gamma of
  the input.

  https://numerical.recipes/book.html
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

  @spec exponentiate_int(number(), non_neg_integer()) :: number()
  def exponentiate_int(x, n) do
    case n <= 0 do
      true -> 1
      false -> x * exponentiate_int(x, n - 1)
    end
  end

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

  def inv_inc_beta(a, b, x) do
    case x > (a + 1.0) / (a + b + 2.0) do
      true ->
        1.0 - inv_inc_beta_wrapper(b, a, 1.0 - x)

      false ->
        inv_inc_beta_wrapper(a, b, x)
    end
  end

  defp inv_inc_beta_wrapper(a, b, x) do
    lbeta_ab = loggamma(a) + loggamma(b) - loggamma(a + b)
    mult = exp(log(x) * a + log(1.0 - x) * b - lbeta_ab) / a
    contfrac = lentz_loop(1.0, 0.0, 1.0, 0, a, b, x)
    mult * (contfrac - 1.0)
  end

  defp clip(value) do
    tinyfloat = 1.0e-30

    case abs(value) < tinyfloat do
      true -> tinyfloat
      false -> value
    end
  end

  defp d_n(n, _, _, _) when n == 0 do
    1
  end

  defp d_n(n, a, b, x) when Integer.is_even(n) do
    m = div(n, 2)
    m * (b - m) * x / ((a + 2.0 * m - 1.0) * (a + 2.0 * m))
  end

  defp d_n(n, a, b, x) do
    m = div(n, 2)
    -((a + m) * (a + b + m) * x) / ((a + 2.0 * m) * (a + 2.0 * m + 1.0))
  end

  defp lentz_loop(c, d, f, n, a, b, x) do
    unless n <= 250 do
      raise ArgumentError,
        message: "the loop has received an invalid number of iterations #{inspect(n)}"
    end

    epsilon = 1.0e-8
    numerator = d_n(n, a, b, x)
    d_denom = clip(1.0 + numerator * d)
    dprime = 1.0 / d_denom
    cprime = clip(1.0 + numerator / c)
    cd = cprime * dprime
    fprime = f * cd

    case abs(1.0 - cd) < epsilon do
      true -> fprime
      false -> lentz_loop(cprime, dprime, fprime, n + 1, a, b, x)
    end
  end
end
