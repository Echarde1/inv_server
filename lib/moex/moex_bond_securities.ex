defmodule Bonds.Securities do
  use TypeStruct

  @secid "-SECID"
  @list_level "-LISTLEVEL"
  @prev_price "-PREVPRICE"
  @coupon_percent "-COUPONPERCENT"
  @board_id "-BOARDID"
  @lowest_list_level Bitwise.bsl(1, 32)

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
                                           |> map_to_struct

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
    cache_pid = Cache.Set.new()
    Utils.build_secid_duplicates_set(securities_list, cache_pid)
    secid_duplicates_set = Cache.Set.get_entries(cache_pid)

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

  defp map_to_struct(securities_list), do:
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

end
