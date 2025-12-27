defmodule Test.Support.Helper do
  def percentage_error(estimated, actual) do
    abs(estimated - actual) / actual
  end
end
