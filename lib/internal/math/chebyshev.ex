defmodule Internal.Math.Chebyshev do
  @moduledoc """
  A Chebyshev polynomial of the first kind is defined by the
  following recurrence:

    T_0(x)     = 1
    T_1(x)     = x
    T_{n+1}(x) = 2xT_n(x) - T_{n-1}(x)

  You should never need to call these functions directly. They are
  used to expand polynomials to approximate mathematical functions like
  log1p, etc.
  """

  @doc """
  Evaluates a Chebyshev polynomial of the first kind using Broucke's
  ECHEB algorithm: https://people.math.sc.edu/Burkardt/f_src/toms446/toms446.f90

  Note that for this implementation, the coefficients are processed last-to-first.

  This is a convention that is used by the original FORTRAN code, as well as
  its descendants in R (https://github.com/SurajGupta/r-source/blob/master/src/nmath/log1p.c)
  and Haskell (https://github.com/haskell/math-functions/blob/eeab264cae6f49ee10ba3c0633551250e17945a0/Numeric/Polynomial/Chebyshev.hs#L53)

  I am quite superstitious, so I will maintain this convention.
  """
  @spec echeb(number(), tuple()) :: number()
  def echeb(x, coeffs) do
    {c0, _, c2} =
      Enum.reduce(
        (tuple_size(coeffs) - 1)..0//-1,
        {0.0, 0.0, 0.0},
        fn k, {b0, b1, _} ->
          {elem(coeffs, k) + 2.0 * x * b0 - b1, b0, b1}
        end
      )

    (c0 - c2) * 0.5
  end
end
