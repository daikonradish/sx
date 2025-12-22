defmodule Math do
  @spec sqrt(number) :: number()
  defdelegate sqrt(n), to: :math

  @spec pow(number, number) :: number()
  defdelegate pow(n, p), to: :math

  @spec log(number) :: number()
  defdelegate log(n), to: :math

  @spec exp(number) :: number()
  defdelegate exp(n), to: :math

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
end
