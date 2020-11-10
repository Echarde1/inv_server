defmodule Moex.Bonds do
  use TypeStruct

  defstruct ListBond,
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
            board_id: str, # Идентификатор режима торгов
            duration: integer # Дюрация

  def parse_bonds_list_xml(xml_doc) do
    data_map = xml_doc
               |> XmlToMap.naive_map
               |> Map.fetch!("document")
               |> Map.fetch!("data")

    securities = data_map
                 |> get_securities_rows_list
                 |> Bonds.ListSecurities.map_securities

    market_data = get_market_data_rows_list(data_map)
                  |> Bonds.ListMarketData.map_market_data(securities)

    market_data_map = Map.new(market_data, fn x -> {x.secid, x} end)
    Enum.map(securities, fn x ->

      case Map.fetch(market_data_map, x.secid) do
        :error -> map_to_bond_struct(x)
        {:ok, market_data_struct} -> map_to_bond_struct(x, market_data_struct.duration)
      end
    end)
  end

  def parse_bond_security_details(xml_doc) do
    xml_doc
    |> XmlToMap.naive_map
    |> get_security_details
    |> Bonds.Details.map_security_details
  end

  defp get_securities_rows_list(data_map), do: data_map
                                               |> List.first
                                               |> Map.fetch!("#content")
                                               |> Map.fetch!("rows")
                                               |> Map.fetch!("row")

  defp get_market_data_rows_list(data_map), do: data_map
                                                |> List.first
                                                |> Map.fetch!("#content")
                                                |> Map.fetch!("rows")
                                                |> Map.fetch!("row")

  defp get_security_details(data_map), do: data_map
                                           |> Map.fetch!("document")
                                           |> Map.fetch!("data")
                                           |> List.first
                                           |> Map.fetch!("#content")
                                           |> Map.fetch!("rows")
                                           |> Map.fetch!("row")

  defp map_to_bond_struct(security, duration \\ 0), do: %ListBond{
    secid: security.secid,
    isin: security.isin,
    sec_name: security.sec_name,
    board_id: security.board_id,
    maturity_date: security.maturity_date,
    offer_date: security.offer_date,
    prev_price: security.prev_price,
    list_level: security.list_level,
    coupon_percent: security.coupon_percent,
    accumulated_coupon_income: security.accumulated_coupon_income,
    coupon_value: security.coupon_value,
    duration: duration
  }

end