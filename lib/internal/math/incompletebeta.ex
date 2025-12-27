defmodule Internal.Math.IncompleteBeta do
  require Integer
  @moduledoc false
  def incomplete_beta(a, b, x) do
    unless x >= 0 and x <= 1 do
      raise ArgumentError, message: "x must be in the range of [0, 1], you gave #{inspect(x)}"
    end

    cond do
      x == 0 or x == 1 ->
        x

      x > (a + 1.0) / (a + b + 2.0) ->
        1.0 - beta_continued_fraction_solver(b, a, 1.0 - x)

      true ->
        beta_continued_fraction_solver(a, b, x)
    end
  end

  defp beta_continued_fraction_solver(a, b, x) do
    lbeta_ab = Math.loggamma(a) + Math.loggamma(b) - Math.loggamma(a + b)
    mult = Math.exp(Math.log(x) * a + Math.log(1.0 - x) * b - lbeta_ab) / a
    contfrac = lentz_loop(1.0, 0.0, 1.0, 0, a, b, x)
    mult * (contfrac - 1.0)
  end

  defp clip(value) do
    # If the absolute value is less than tinyfloat, clip to
    # tinyfloat. In this case it's so small whether it's positive
    # or negative doesn't matter. All we need is to avoid division by zero
    # error.
    tinyfloat = 1.0e-30

    case abs(value) < tinyfloat do
      true -> tinyfloat
      false -> value
    end
  end

  defp d_n(n, _, _, _) when n == 0 do
    # Incomplete beta can be expressed as a continued fraction.
    # d_n is typically used as the notation for the numerator.
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

  @doc """
  Lentz algorithm for solving continued fractions.

  https://en.wikipedia.org/wiki/Lentz%27s_algorithm
  """
  def lentz_loop(c, d, f, n, a, b, x) do
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

  # brcomp(a, b, x, y) do
  #   case {x == 0.0, y == 0.0} do
  #     {true, _} -> 0.0
  #     {_, true} -> 0.0
  #     {_, _} ->
  #       a0 = min(a, b)
  #       {lnx, lny} = cond do
  #         x <= 0.375 -> {Math.log()}
  #       end
  #   end
  # end
end
