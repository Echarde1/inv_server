defmodule MoexBondsTest do
  use ExUnit.Case, async: true

  test "parse_xml" do
    correct_result = [
      %Bonds.Securities.Security{
        accumulated_coupon_income: "37",
        board_id: "TQCB",
        coupon_percent: "9.25",
        coupon_value: "46.12",
        isin: "RU000A1008B1",
        list_level: 1,
        maturity_date: "2029-03-21",
        offer_date: "2022-04-04",
        prev_price: 103.7,
        sec_name: "Тинькофф Банк БО 001Р-02R",
        secid: "RU000A1008B1"
      },
      %Bonds.Securities.Security{
        accumulated_coupon_income: "13.61",
        board_id: "TQOB",
        coupon_percent: "7",
        coupon_value: "34.9",
        isin: "RU000A0ZYCK6",
        list_level: 1,
        maturity_date: "2021-12-15",
        offer_date: "",
        prev_price: 103.3,
        sec_name: "ОФЗ-ПД 25083 15/12/21",
        secid: "SU25083RMFS5"
      },
      %Bonds.Securities.Security{
        accumulated_coupon_income: "12.54",
        board_id: "TQOB",
        coupon_percent: "7.38",
        coupon_value: "36.8",
        isin: "RU000A0JV4Q1",
        list_level: 1,
        maturity_date: "2034-12-06",
        offer_date: "",
        prev_price: 109.095,
        sec_name: "ОФЗ-ПК 29010 06/12/34",
        secid: "SU29010RMFS4"
      }
    ]

    {:ok, xml_doc} = File.read(Path.expand("test/mock/moex_all_bonds.xml"))
    #    {:ok, xml_doc} = File.read(Path.expand("test/mock/moex_securities.xml"))
    result = Moex.Bonds.parse_bonds_list_xml(xml_doc)

    assert correct_result == result
  end
end