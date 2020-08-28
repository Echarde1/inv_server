defmodule Bonds.Securities do
  use TypeStruct

  @secid "-SECID"
  @list_level "-LISTLEVEL"
  @prev_price "-PREVPRICE"
  @coupon_percent "-COUPONPERCENT"
  @board_id "-BOARDID"
  @lowest_list_level 2

  # можно найти на https://iss.moex.com/iss/engines/stock/markets/bonds.xml
  @bonds_board_ids MapSet.new(
                     [
                       "TQOB",
                       "TQOD",
                       "TQCB",
                       "TQOE"
                     ]
                   )

  defstruct Security,
            secid: str, # Идентификатор для мосбиржи
            isin: str, # Общий идентификатор облигации
            sec_name: str,
            offer_date: Date, #Дата оферты
            maturity_date: Date, #Дата погашения
            prev_price: float,
            coupon_percent: float, # Ставка купона
            accumulated_coupon_income: float, # НКД
            coupon_value: float,
            list_level: integer,
            board_id: str # Идентификатор режима торгов

  def map_securities(securities_list), do: securities_list
                                           |> filter_board_id
                                           |> filter_prev_price
                                           |> filter_list_level
                                           |> filter_secid_duplicates
                                           |> map_raw_bond

  defp filter_board_id(securities_list), do: securities_list
    |> Enum.filter(
         &MapSet.member?(
           @bonds_board_ids,
           Map.fetch!(&1, @board_id)
         )
       )

  defp filter_prev_price(securities_list) do
    predicate = fn (price) ->
      Utils.is_not_empty_string(price) && Utils.parse_float(price) >= 0
    end

    securities_list
    |> Enum.filter(
         fn x ->
           prev_price = Map.fetch!(x, @prev_price)
           predicate.(prev_price)
         end
       )
  end

  defp filter_list_level(securities_list, level \\ @lowest_list_level), do:
    securities_list
    |> Enum.filter(
         &Map.fetch!(&1, @list_level)
          |> Utils.parse_int <= level
       )

  defp filter_coupon_percent(securities_list, percent \\ 0), do:
    securities_list
    |> Enum.filter(
         &Map.fetch!(&1, @coupon_percent)
          |> Utils.parse_float >= percent
       )

  # Есть лишние режимы торгов для некоторых бумаг, из-за чего возникают дубликаты
  defp filter_secid_duplicates(securities_list) do
    cache_set_pid = Cache.Set.new()
    build_secid_duplicates_set(securities_list, cache_set_pid)
    secid_duplicates_set = Cache.Set.get_entries(cache_set_pid)

    Enum.filter(
      securities_list,
      fn x ->
        secid = Map.fetch!(x, @secid)

        if MapSet.member?(secid_duplicates_set, secid) do
          Map.fetch!(x, @board_id) == "TQOD"
        else
          true
        end
      end
    )
  end

  defp map_raw_bond(securities_list), do:
    securities_list
    |> Enum.map(
         fn x ->
           %Security{
             secid: Map.fetch!(x, @secid),
             isin: Map.fetch!(x, "-ISIN"),
             sec_name: Map.fetch!(x, "-SECNAME"),
             board_id: Map.fetch!(x, @board_id),
             maturity_date: Map.fetch!(x, "-MATDATE"), # Нужно будет привести к дате
             offer_date: Map.fetch!(x, "-OFFERDATE"), # Нужно будет привести к дате
             prev_price: Map.fetch!(x, @prev_price)
                         |> Utils.parse_float,
             list_level: Map.fetch!(x, @list_level)
                         |> Utils.parse_int,
             coupon_percent: Map.fetch!(x, @coupon_percent),
             accumulated_coupon_income: Map.fetch!(x, "-ACCRUEDINT"),
             coupon_value: Map.fetch!(x, "-COUPONVALUE"),
           }
         end
       )

  defp build_secid_duplicates_set([head | tail], cache_set_pid) do
    fun = fn x ->
      [head | tail] = x
      list_contains_secid(tail, head, cache_set_pid)
    end

    fun.([head | tail])
    build_secid_duplicates_set(tail, cache_set_pid)
  end

  defp build_secid_duplicates_set([], _), do: nil

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
