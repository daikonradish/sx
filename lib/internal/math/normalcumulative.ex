defmodule Internal.Math.NormalCumulative do
  # https://github.com/SurajGupta/r-source/blob/master/src/nmath/pnorm.c
  # Which is a C port of https://people.math.sc.edu/Burkardt/f_src/specfun/specfun.f90
  @msqrt32 5.656854249492380195206754896838
  @sixten 16.0
  @oneoversqrttwopi 0.398942280401432677939946059934
  # Coefficients for the first segment
  @a {
    2.2352520354606839287,
    161.02823106855587881,
    1067.6894854603709582,
    18154.981253343561249,
    0.065682337918207449113
  }

  @b {
    47.20258190468824187,
    976.09855173777669322,
    10260.932208618978205,
    45507.789335026729956
  }

  # Coefficients for the first segment
  @c {
    0.39894151208813466764,
    8.8831497943883759412,
    93.506656132177855979,
    597.27027639480026226,
    2494.5375852903726711,
    6848.1904505362823326,
    11602.651437647350124,
    9842.7148383839780218,
    1.0765576773720192317e-8
  }

  @d {
    22.266688044328115691,
    235.38790178262499861,
    1519.377599407554805,
    6485.558298266760755,
    18615.571640885098091,
    34900.952721145977266,
    38912.003286093271411,
    19685.429676859990727
  }

  @p {
    0.21589853405795699,
    0.1274011611602473639,
    0.022235277870649807,
    0.001421619193227893466,
    2.9112874951168792e-5,
    0.02307344176494017303
  }

  @q {
    1.28426009614491121,
    0.468238212480865118,
    0.0659881378689285515,
    0.00378239633202758244,
    7.29751555083966205e-5
  }

  def pnorm(x) do
    y = abs(x)

    cond do
      y <= 0.67448975 -> pnorm_lt67448975(x, y)
      y <= @msqrt32 -> pnorm_ltsqrt32(x, y)
      -37.5193 < x and x < 8.2924 -> pnorm_bigval(x, y)
      # otherwise x is too big, just give P(X<=x) = 1.0
      x > 0 -> 1.0
      # otherwise x is too small, just give P(X<=x) = 0.0
      true -> 0.0
    end
  end

  defp pnorm_lt67448975(x, y) do
    # Check that y <= 0.67448975
    eps = 2.2204e-16 * 0.5

    {xnum, xden} =
      case y > eps do
        true ->
          xsq = x * x
          xsqa4 = xsq * elem(@a, 4)

          {0..2 |> Enum.reduce(xsqa4, fn n, acc -> (acc + elem(@a, n)) * xsq end),
           0..2 |> Enum.reduce(xsq, fn n, acc -> (acc + elem(@b, n)) * xsq end)}

        false ->
          {0.0, 0.0}
      end

    temp = x * (xnum + elem(@a, 3)) / (xden + elem(@b, 3))
    0.5 + temp
  end

  defp pnorm_ltsqrt32(x, y) do
    xnumc8y = elem(@c, 8) * y
    xdeny = y

    xnum = 0..6 |> Enum.reduce(xnumc8y, fn n, acc -> (acc + elem(@c, n)) * y end)
    xden = 0..6 |> Enum.reduce(xdeny, fn n, acc -> (acc + elem(@d, n)) * y end)
    temp = (xnum + elem(@c, 7)) / (xden + elem(@d, 7))

    xsq = trunc(x * @sixten) / @sixten
    del = (x - xsq) * (x + xsq)
    result = Math.exp(-xsq * xsq * 0.5) * Math.exp(-del * 0.5) * temp

    case x > 0.0 do
      true -> 1.0 - result
      false -> result
    end
  end

  defp pnorm_bigval(x, y) do
    xsq = 1.0 / (x * x)
    xnump5 = xsq * elem(@p, 5)
    xdenxs = xsq

    xnum = 0..3 |> Enum.reduce(xnump5, fn n, acc -> (acc + elem(@p, n)) * xsq end)
    xden = 0..3 |> Enum.reduce(xdenxs, fn n, acc -> (acc + elem(@q, n)) * xsq end)

    temp = xsq * (xnum + elem(@p, 4)) / (xden + elem(@q, 4))
    temp2 = (@oneoversqrttwopi - temp) / y

    ysq = trunc(x * @sixten) / @sixten
    del = (x - ysq) * (x + ysq)
    result = Math.exp(-ysq * ysq * Math.exp(-del * temp2))

    case x > 0.0 do
      true -> 1.0 - result
      false -> result
    end
  end
end
