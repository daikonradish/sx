defmodule Internal.Math.Beta do
  use Internal.Math.Constants

  # static double bfrac(double, double, double, double, double, double, int log_p);
  # static void bgrat(double, double, double, double, double *, double, int *, Rboolean log_w);
  # static double grat_r(double a, double x, double r, double eps);
  # static double apser(double, double, double, double);
  # static double bpser(double, double, double, double, int log_p);
  # static double basym(double, double, double, double, int log_p);
  # static double fpser(double, double, double, double, int log_p);
  # static double bup(double, double, double, double, int, double, int give_log);
  # static double exparg(int);
  # static double psi(double);
  # static double gam1(double);
  # [DONE] static double gamln1(double);
  # static double betaln(double, double);
  # [DONE] static double algdiv(double, double);
  # static double brcmp1(int, double, double, double, double, int give_log);
  # static double brcomp(double, double, double, double, int log_p);
  # static double rlog1(double);
  # static double bcorr(double, double);
  # [DONE] static double gamln(double);
  # [DONE -- Math.log1p] static double alnrel(double);
  # static double esum(int, double, int give_log);
  # static double erf__(double);
  # static double rexpm1(double);
  # static double erfc1(int, double);
  # static double gsumln(double, double);

  @doc """
  Computes the constant factor used in `bfrac`.
  """
  @spec brcomp(number(), number(), number(), number()) :: number()
  def brcomp(a, b, x, y) do
    # use @m_1_sqrt_2_pi, approx = 0.398942280401433
    cond do
      x == 0.0 or y == 0.0 ->
        0.0

      true ->
        a0 = min(a, b)
        b0 = max(a, b)

        {lnx, lny} =
          cond do
            x <= 0.375 -> {Math.log(x), Math.log1p(-x)}
            y > 0.375 -> {Math.log(x), Math.log(y)}
            true -> {Math.log1p(-y), Math.log(y)}
          end

        z = a * lnx + b * lny

        # Leaving for holiday now.
        # Pick back up here: https://github.com/SurajGupta/r-source/blob/a28e609e72ed7c47f6ddfbb86c85279a0750f0b7/src/nmath/toms708.c#L842
        cond do
          a0 >= 1.0 -> nil
          true -> nil
        end
    end
  end

  @doc """
  Evaluation of ln(Beta(a, b)) = ln(Γ(a)) + ln(Γ(b)) - ln(Γ(a+b))
  """
  @spec betaln(number(), number()) :: number()
  def betaln(a0, b0) do
    # e == 0.5*LN(2*PI)
    e = 0.918938533204673
    a = min(a0, b0)
    b = max(a0, b0)

    cond do
      a < 1.0 ->
        cond do
          b < 8.0 -> gamln(a) + gamln(b) - gamln(a + b)
          true -> gamln(a) + algdiv(a, b)
        end

      a < 8.0 ->
        cond do
          a <= 2.0 and b <= 2.0 -> gamln(a) + gamln(b) - gsumln(a, b)
          a <= 2.0 and b >= 8.0 -> gamln(a) + algdiv(a, b)
          true -> nil
        end

      true ->
        nil
    end
  end

  @doc """
  Evaluation of ln(gamma(a + b))
  for 1 <= a <= 2  AND  1 <= b <= 2

  Caller's responsibility to ensure that a and b are in this range.
  """
  @spec gsumln(number(), number()) :: number()
  def gsumln(a, b) do
    x = a + b - 2.0

    cond do
      x <= 0.25 -> gamln1(x + 1.0)
      x <= 1.25 -> gamln1(x) + Math.log1p(x)
      true -> gamln1(x - 1.0) + Math.log(x * (x + 1.0))
    end
  end

  @doc """
  Evaluation of ln(gamma(b)/gamma(a+b)) WHEN b >= 8

  Caller's responsiblity to ensure that this is the case.
  """
  @spec algdiv(number(), number()) :: number()
  def algdiv(a, b) do
    c0 = 0.0833333333333333
    c1 = -0.00277777777760991
    c2 = 7.9365066682539e-4
    c3 = -5.9520293135187e-4
    c4 = 8.37308034031215e-4
    c5 = -0.00165322962780713

    {h, c, x, d} =
      case a > b do
        true ->
          h1 = b / a
          {h1, 1.0 / (h1 + 1.0), h1 / (h1 + 1.0), a + (b - 0.5)}

        false ->
          h1 = a / b
          {h1, h1 / (h1 + 1.0), 1.0 / (h1 + 1.0), b + (a - 0.5)}
      end

    x2 = x * x
    s3 = x + x2 + 1.0
    s5 = x + x2 * s3 + 1.0
    s7 = x + x2 * s5 + 1.0
    s9 = x + x2 * s7 + 1.0
    s11 = x + x2 * s9 + 1.0
    t = 1.0 / (b * b)

    w1 =
      ((((c5 * s11 * t + c4 * s9) * t + c3 * s7) * t + c2 * s5) * t +
         c1 * s3) * t + c0

    w = w1 * (c / b)

    u = d * Math.log1p(a / b)
    v = a * (Math.log(b) - 1.0)

    case u > v do
      true -> w - v - u
      false -> w - u - v
    end
  end

  @doc """
  Evaluation of ln(gamma(a)) for a > 0

  Originally written by Alfred H. Morris
            Naval Surface Warfare Center
            Dahlgren, Virginia

  Translated into Elixir by Jireh Tan
  """
  @spec gamln(number()) :: number()
  def gamln(a) do
    # TODO see if you can replace this by loggamma()
    cond do
      a <= 0.8 ->
        gamln1(a) - Math.log(a)

      a <= 2.25 ->
        # IDK why they didn't just subtract 1, but
        # at this point I'm very superstitious.
        gamln1(a - 0.5 - 0.5)

      a < 10.0 ->
        n = trunc(a - 1.25)

        {t, w} =
          Enum.reduce(
            1..n,
            {a, 1.0},
            fn _, {t1, w1} ->
              tnew = t1 - 1.0
              {tnew, w1 * tnew}
            end
          )

        gamln1(t - 1.0) + Math.log(w)

      # a >= 10
      true ->
        d = 0.418938533204673
        c0 = 0.0833333333333333
        c1 = -0.00277777777760991
        c2 = 7.9365066682539e-4
        c3 = -5.9520293135187e-4
        c4 = 8.37308034031215e-4
        c5 = -0.00165322962780713
        t = 1.0 / (a * a)
        w = (((((c5 * t + c4) * t + c3) * t + c2) * t + c1) * t + c0) / a
        d + w + (a - 0.5) * (Math.log(a) - 1.0)
    end
  end

  @doc """
  Evaluation of ln(gamma(1 + a)) for -0.2 <= a <= 1.25

  Originally written by Alfred H. Morris
            Naval Surface Warfare Center
            Dahlgren, Virginia

  Translated into Elixir by Jireh Tan

  Caller's responsibility to ensure a lies in this interval
  """
  @spec gamln1(number()) :: number()
  def gamln1(a) do
    case a < 0.6 do
      true ->
        p0 = 0.577215664901533
        p1 = 0.844203922187225
        p2 = -0.168860593646662
        p3 = -0.780427615533591
        p4 = -0.402055799310489
        p5 = -0.0673562214325671
        p6 = -0.00271935708322958
        q1 = 2.88743195473681
        q2 = 3.12755088914843
        q3 = 1.56875193295039
        q4 = 0.361951990101499
        q5 = 0.0325038868253937
        q6 = 6.67465618796164e-4

        w =
          ((((((p6 * a + p5) * a + p4) * a + p3) * a + p2) * a + p1) * a + p0) /
            ((((((q6 * a + q5) * a + q4) * a + q3) * a + q2) * a + q1) * a + 1.0)

        -a * w

      false ->
        r0 = 0.422784335098467
        r1 = 0.848044614534529
        r2 = 0.565221050691933
        r3 = 0.156513060486551
        r4 = 0.017050248402265
        r5 = 4.97958207639485e-4
        s1 = 1.24313399877507
        s2 = 0.548042109832463
        s3 = 0.10155218743983
        s4 = 0.00713309612391
        s5 = 1.16165475989616e-4
        x = a - 0.5 - 0.5

        w =
          (((((r5 * x + r4) * x + r3) * x + r2) * x + r1) * x + r0) /
            (((((s5 * x + s4) * x + s3) * x + s2) * x + s1) * x + 1.0)

        x * w
    end
  end
end
