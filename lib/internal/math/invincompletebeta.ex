defmodule Internal.Math.InvIncompleteBeta do
  alias Internal.Math.IncompleteBeta

  def inv_incomplete_beta(a, b, p) do
    cond do
      p <= 0.0 ->
        0.0

      p >= 1.0 ->
        1.0

      true ->
        guess =
          case a > 1.0 and b > 1.0 do
            true ->
              mu = a / (a + b)
              sigma = Math.sqrt(a * b / ((a + b) ** 2.0 * (a + b + 1.0)))
              x = mu + sigma * (2.0 * p - 1.0)
              # Clamp x to 0.01 and 0.99
              max(0.01, min(0.99, x))

            false ->
              0.5
          end

        betaab = Math.loggamma(a + b) - Math.loggamma(a) - Math.loggamma(b)

        newton_halley_iterate(guess, 0.0, 1.0, 0, p, a, b, betaab)
    end
  end

  def newton_halley_iterate(x, x_low, x_high, n, p, a, b, betaab) do
    epsilon = 1.0e-8
    riskofunderflow = 1.0e-20

    unless n < 15 do
      raise ArgumentError, message: "original guess was bad, more than 100 iteratiosn!"
    end

    fx = IncompleteBeta.incomplete_beta(a, b, x) - p

    {new_low, new_high} =
      case fx < 0 do
        true -> {max(0.0, x), min(x_high, 1.0)}
        false -> {max(0.0, x_low), min(x, 1.0)}
      end

    x_bisected =
      cond do
        x < 0 -> x
        x < 1 -> (new_low + new_high) / 2
        true -> 1
      end

    logpdf = (a - 1.0) * Math.log(x) + (b - 1.0) * Math.log(1.0 - x) + betaab
    fprimex = Math.exp(logpdf)

    fprimeprimex = fprimex * ((a - 1) / x - (b - 1) / (1 - x))
    denominator = fprimex - 0.5 * fx * fprimeprimex / fprimex

    x_halley =
      case denominator < riskofunderflow do
        ## Just fallback to newton,
        true -> x - fx / fprimex
        ## Otherwise use Halley, up to third derivative.
        false -> x - fx / denominator
      end

    cond do
      # the pdf is the derivative of the CDF. if the pdf is close to zero
      # then indeed we have achieved convergence according to Newton-Raphson
      # or Halley, or any of the iterative methods which use the first derivative.
      abs(fx) < epsilon ->
        x

      abs(x_halley - x) < epsilon ->
        x_halley

      # bisect the search space if we're too far away. This is not
      # Newton-Raphson or Halley, it's just a shortcut.
      x <= 0 or x >= 1 ->
        newton_halley_iterate(x_bisected, new_low, new_high, n + 1, p, a, b, betaab)

      fprimex < riskofunderflow ->
        newton_halley_iterate(x_bisected, new_low, new_high, n + 1, p, a, b, betaab)

      x_halley < new_low or x_halley > new_high ->
        newton_halley_iterate(x_bisected, new_low, new_high, n + 1, p, a, b, betaab)

      true ->
        newton_halley_iterate(x_halley, new_low, new_high, n + 1, p, a, b, betaab)
    end
  end
end
