defmodule Utils do

  @secid "-SECID"
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

  def build_secid_duplicates_set([head | tail], cache_set_pid) do
    fun = fn x ->
      [head | tail] = x
      list_contains_secid(tail, head, cache_set_pid)
    end

    fun.([head | tail])
    build_secid_duplicates_set(tail, cache_set_pid)
  end

  def build_secid_duplicates_set([], _), do: nil

  defp list_contains_secid([head | tail], el, cache_set_pid) do
    head_secid = Map.fetch!(head, @secid)
    el_secid = Map.fetch!(el, @secid)
    if head_secid == el_secid do
      Cache.Set.add_entry(cache_set_pid, el_secid)
    end

    list_contains_secid(tail, el, cache_set_pid)
  end

  defp list_contains_secid([], _, _), do: nil

end