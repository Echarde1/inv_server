defmodule Utils do

  @empty_string ""
  @type str :: String.t()

  def is_empty_string(string), do: String.strip(string) == @empty_string
  def is_not_empty_string(string), do: !is_empty_string(string)

  @spec parse_int(str) :: integer
  def parse_int(str), do: str
                          |> Integer.parse
                          |> elem(0)

  @spec parse_float(str) :: float
  def parse_float(str), do: str
                          |> Float.parse
                          |> elem(0)

end