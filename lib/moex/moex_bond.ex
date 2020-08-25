defmodule Inv.Moex.Bond do
  use TypeStruct

  @list_level "-LISTLEVEL"
  @prev_price "-PREVPRICE"

  defstruct Bond,
            isin: str,
            sec_name: str,
            maturity_date: Date,
              #Дата погашения
            prev_price: float,
            list_level: integer

  def parse_xml_bonds_list(xml_doc) do
    xml_doc
    |> get_rows_list
    |> Enum.filter(
         # Фильтруем пустые данные. Имеются дубли с заполненными данными
         &Utils.is_not_empty_string(
           Map.fetch!(&1, @prev_price)
         )
       )
    |> filter_list_level(3)
      #    |> Enum.take(1)
    |> make_raw_bond
  end

  def parse_xml_bond_details(xml_doc) do
    xml_doc
    |> XmlToMap.naive_map()
    |> Map.fetch!("document")
    |> Map.fetch!("data")
    |> List.first
    |> Map.fetch!("#content")
    |> Map.fetch!("rows")
    |> Map.fetch!("row")
    #    |> Enum.map(fn x ->
    #      %Inv.Moex.Bond{
    #        name: Map.fetch!(x, "-name"),
    #        title: Map.fetch!(x, "-title"),
    #        value: Map.fetch!(x, "-value")
    #      }
    #    end)
  end

  defp get_rows_list(xml_doc), do: xml_doc
                                   |> XmlToMap.naive_map()
                                   |> Map.fetch!("document")
                                   |> Map.fetch!("data")
                                   |> List.first
                                   |> Map.fetch!("#content")
                                   |> Map.fetch!("rows")
                                   |> Map.fetch!("row")

  defp filter_list_level(bonds_list, level), do: bonds_list
  |> Enum.filter(
      &Map.fetch!(&1, @list_level) |> Utils.parse_int < level
    )

  defp make_raw_bond(bonds_list) do
    Enum.map(
      bonds_list,
      fn x ->
        %Bond{
          isin: Map.fetch!(x, "-ISIN"),
          sec_name: Map.fetch!(x, "-SECNAME"),
          maturity_date: Map.fetch!(x, "-MATDATE"),
          prev_price: Map.fetch!(x, @prev_price) |> Utils.parse_float,
          list_level: Map.fetch!(x, @list_level) |> Utils.parse_int
        }
      end
    )
  end
end
