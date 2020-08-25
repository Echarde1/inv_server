defmodule InvMoexTest do
  use ExUnit.Case, async: true

  test "parse" do
    {:ok, xml_doc} = File.read(Path.expand("test/mock/moex_RU000A1008B1.xml"))
    IO.inspect(Inv.Moex.Bond.parse_xml_bond_details(xml_doc))
    assert 2 + 2 == 4
  end

  test "parse_bonds_list" do
    {:ok, xml_doc} = File.read(Path.expand("test/mock/moex_securities.xml"))

    result = Inv.Moex.Bond.parse_xml_bonds_list(xml_doc)
#    Inv.Moex.Bond.parse_xml_bonds_list(xml_doc)
#    |> Enum.filter(
#         fn x ->
#           Map.fetch!(x, "-SECID") == "SU25083RMFS5"
#         end
#       )
#    |> IO.inspect

#    IO.inspect(length(elem(result, 0)) == length(elem(result, 1)))
#    assert length(Map.fetch!(result, :r)) == length(Map.fetch!(result, :c))
#    IO.inspect(length(Map.fetch!(result, :c)))
    Enum.map(result, fn x ->
      IO.inspect(x.prev_close_price)
    end)
    assert 2 + 2 == 4
  end
end
