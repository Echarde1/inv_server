defmodule Moex.Bonds do

  def parse_bonds_list_xml(xml_doc) do
    data_map = xml_doc
               |> XmlToMap.naive_map()
               |> Map.fetch!("document")
               |> Map.fetch!("data")

    securities = data_map
                 |> get_securities_rows_list
                 |> Bonds.Securities.map_securities
                 |> Enum.sort_by(fn x -> x.secid end)

    secid_set = MapSet.new(securities, fn x -> x.secid end)
    IO.inspect(MapSet.size(secid_set), label: "Secid size ")
    IO.inspect(length(securities), label: "Securities size ")

    market_data = Bonds.MarketData.map_market_data(securities, get_market_data_rows_list(data_map))

#    securities
    market_data
  end

  defp get_securities_rows_list(data_map), do: data_map
                                               |> List.first
                                               |> Map.fetch!("#content")
                                               |> Map.fetch!("rows")
                                               |> Map.fetch!("row")

  defp get_market_data_rows_list(data_map), do: data_map
                                                |> Enum.at(1)
                                                |> Map.fetch!("#content")
                                                |> Map.fetch!("rows")
                                                |> Map.fetch!("row")

end