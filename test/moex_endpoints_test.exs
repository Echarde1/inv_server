defmodule InvMoexEndpointsTest do
  use ExUnit.Case, async: true

  test "parse" do
    path = Path.expand("moex_RU000A1008B1.xml")
    IO.inspect(path)
    {:ok, xml_doc} = File.read(path)
    IO.inspect(Inv.Moex.Endpoints.get_moex_bond_details(xml_doc))
    assert 2 + 2 == 4
  end

end
