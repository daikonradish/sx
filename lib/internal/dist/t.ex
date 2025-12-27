defmodule Internal.Dist.T do
  defstruct [:df]

  def cdf(df, x) do
    xx = df / (x * x + df)
    b = 1.0 - Math.incomplete_beta(df / 2.0, 1 / 2, xx)
    signt = if x >= 0, do: 1.0, else: -1.0
    0.5 * (1 + signt * b)
  end
end
