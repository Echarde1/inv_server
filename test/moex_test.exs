defmodule InvMoexTest do
  use ExUnit.Case, async: true

  test "parse" do
    {:ok, xml_doc} = File.read(Path.expand("test/mock/moex_RU000A1008B1.xml"))
    IO.inspect(Inv.Moex.Bond.parse_xml_bond_details(xml_doc))
    assert 2 + 2 == 4
  end

  test "parse_bonds_list" do
    {:ok, xml_doc} = File.read(Path.expand("test/mock/moex_securities.xml"))

    #    IO.inspect(
    #      Enum.filter(
    #        Inv.Moex.Bond.parse_xml_bonds_list(xml_doc),
    #        fn map ->
    #          Map.fetch!(map, "-ISIN") == "RU000A101FA1"
    #        end
    #      )
    #    )
    result = Inv.Moex.Bond.parse_xml_bonds_list(xml_doc)
    #    IO.inspect(result)
    first = result
            |> List.first
    IO.inspect(first)
    Map.from_struct(first)
    |> Map.fetch!(:isin)
    |> Kernel.is_bitstring
    |> IO.inspect
    assert 2 + 2 == 4
  end
end
