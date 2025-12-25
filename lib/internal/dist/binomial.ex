defmodule Internal.Dist.Binomial do
  @moduledoc false
  defstruct [:n, :p]

  @smallenough 15

  @spec pdf(non_neg_integer(), number(), non_neg_integer()) :: number()
  def pdf(n, p, k) do
    cond do
      p == 0.0 and k == 0.0 ->
        1

      p == 0.0 ->
        0.0

      p == 1.0 and k == n ->
        1.0

      p == 1.0 ->
        0.0

      k == 0 ->
        Math.exp(n * Math.log(1 - p))

      k == n ->
        Math.exp(n * Math.log(p))

      true ->
        lc =
          Math.loggamma(n + 1) - Math.loggamma(k + 1) - Math.loggamma(n - k + 1) +
            k * Math.log(p) + (n - k) * Math.log(1 - p)

        Math.exp(lc)
    end
  end

  def cdf(n, p, x) do
    cond do
      p == 0.0 -> 1
      p == 1.0 -> if x == n, do: 1.0, else: 0.0
      x <= 0 -> 0.0
      x >= n -> 1.0
      n <= @smallenough -> brute_force_search_cdf(n, p, x, 0, 0.0)
      true -> Math.inc_beta(n - x, x + 1, 1 - p)
    end
  end

  def icdf(n, pr, p) do
    cond do
      # If the probability of success is zero, then regardless
      # of the quantile requested, the result is 0.
      pr == 0.0 ->
        0

      # If the probability of success is 1, then regardless
      # of the quantile requested, the result is 0.
      pr == 1.0 ->
        n

      p >= 1.0 ->
        n

      p <= 0.0 ->
        0

      n <= @smallenough ->
        brute_force_search_icdf(n, pr, p, 0, 0.0)

      true ->
        binary_search_icdf(n, pr, p, 0, n)
    end
  end

  def mean(n, p) do
    n * p
  end

  def variance(n, p) do
    n * p * (1 - p)
  end

  def rand_gen(n, p, initial_state) do
    case n <= @smallenough do
      true ->
        Rand.unit_gen(initial_state)
        |> Stream.chunk_every(n)
        |> Stream.map(fn chk -> Enum.count(chk, fn x -> x <= p end) end)

      false ->
        Rand.unit_gen_map(initial_state, fn x -> icdf(n, p, x) end)
    end
  end

  def brute_force_search_cdf(n, pr, k_target, k_curr, acc) do
    # want: P(x <= k)
    case k_curr > k_target do
      true -> acc
      false -> brute_force_search_cdf(n, pr, k_target, k_curr + 1, acc + pdf(n, pr, k_curr))
    end
  end

  def brute_force_search_icdf(n, pr, p_target, k, acc) do
    case k >= n do
      true ->
        n

      false ->
        pnew = acc + pdf(n, pr, k)

        case pnew > p_target do
          true -> k
          false -> brute_force_search_icdf(n, pr, p_target, k + 1, pnew)
        end
    end
  end

  def binary_search_icdf(n, pr, p_target, lobound, hibound) do
    case hibound <= lobound do
      true ->
        lobound

      false ->
        midpt = lobound + div(hibound - lobound, 2)

        case cdf(n, pr, midpt) >= p_target do
          true -> binary_search_icdf(n, pr, p_target, lobound, midpt)
          false -> binary_search_icdf(n, pr, p_target, midpt + 1, hibound)
        end
    end
  end
end
