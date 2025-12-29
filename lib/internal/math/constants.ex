defmodule Internal.Math.Constants do
  defmacro __using__(_) do
    quote do
      # Largest representable finite value
      @m_huge 1.7976931348623157e308

      # Smallest representable positive value
      @m_tiny 2.2250738585072014e-308

      # Largest 'Int' /x/ such that 2**(/x/-1) is
      # representable as a 'Double'.
      @m_max_exp 1024

      # Maximum possible finite value of @log x@
      # ('m_huge')
      @m_max_log 709.782712893384

      # Logarithm of smallest normalized double ('m_tiny')
      @m_min_log -708.3964185322641

      # sqrt(2)
      @m_sqrt_2 1.4142135623730950488016887242096980785696718753769480731766

      # sqrt(2 * pi)
      @m_sqrt_2_pi 2.5066282746310005024157652848110452530069867406099383166299

      # 2 / sqrt(pi)
      @m_2_sqrt_pi 1.1283791670955125738961589031215451716881012586579977136881

      # 1 / sqrt(2)
      @m_1_sqrt_2 0.7071067811865475244008443621048490392848359376884740365883

      # 1 / sqrt(2 * pi)
      @m_1_sqrt_2_pi 0.39894228040143267793994644226162355531505365514682

      # Smallest value of x such that 1 + x is not equal to 1.
      # Anything smaller than this will result in 1 + x rounded off to 1.
      @m_epsilon 2.220446049250313e-16

      # sqrt(m_epsilon)
      @m_sqrt_eps 1.4901161193847656e-08

      # log(sqrt(2 * pi))
      @m_ln_sqrt_2_pi 0.9189385332046727417803297364056176398613974736377834128171
    end
  end
end
