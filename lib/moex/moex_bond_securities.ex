defmodule Bond.Securities do
  use TypeStruct

  @list_level "-LISTLEVEL"
  @prev_price "-PREVPRICE"
  @coupon_percent "-COUPONPERCENT"
  @board_id "-BOARDID"
  @lowest_list_level 2

  @bonds_board_ids MapSet.new(
                     # можно найти на https://iss.moex.com/iss/engines/stock/markets/bonds.xml
                     [
                       "TQOB",
                       "TQOD",
                       "TQCB",
                       "TQOE"
                     ]
                   )

  defstruct Securities,
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

  def parse_xml_bonds_list(xml_doc) do
    xml_doc
    |> get_securities_rows_list
    |> filter_board_id
    |> filter_prev_price
    |> filter_list_level
    |> map_raw_bond
  end

  defp get_securities_rows_list(xml_doc), do: xml_doc
                                              |> XmlToMap.naive_map()
                                              |> Map.fetch!("document")
                                              |> Map.fetch!("data")
                                              |> List.first
                                              |> Map.fetch!("#content")
                                              |> Map.fetch!("rows")
                                              |> Map.fetch!("row")

  defp filter_board_id(bonds_list), do:
    bonds_list
    |> Enum.filter(
         &MapSet.member?(
           @bonds_board_ids,
           Map.fetch!(&1, @board_id)
         )
       )

  defp filter_prev_price(bonds_list) do
    predicate = fn (price) ->
      Utils.is_not_empty_string(price) && Utils.parse_float(price) >= 0
    end

    bonds_list
    |> Enum.filter(
         fn x ->
           prev_price = Map.fetch!(x, @prev_price)
           predicate.(prev_price)
         end
       )
  end

  defp filter_list_level(bonds_list, level \\ @lowest_list_level), do:
    bonds_list
    |> Enum.filter(
         &Map.fetch!(&1, @list_level)
          |> Utils.parse_int <= level
       )

  defp filter_coupon_percent(bonds_list, percent \\ 0), do:
    bonds_list
    |> Enum.filter(
         &Map.fetch!(&1, @coupon_percent)
          |> Utils.parse_float >= percent
       )

  defp map_raw_bond(bonds_list) do
    Enum.map(
      bonds_list,
      fn x ->
        %Securities{
          secid: Map.fetch!(x, "-SECID"),
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
end
