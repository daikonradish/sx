defmodule Internal.Math.ContFrac do
  require Integer
  @moduledoc false

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
end
