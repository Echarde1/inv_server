defmodule Inv.Moex.Endpoints do
  require Logger

  @base_url Application.get_env(:my_inv_app, :moex_base_url)

  def get_moex_bond_details(ticker) do
    case HTTPoison.get(@base_url <> "/securities/RU000A1008B1") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.info("Moex bond with ticker #{ticker} info body: #{body}")
        parse_xml_bond_data(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error("Moex bond with ticker #{ticker} details fetch page not found")
        "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Moex bond with ticker #{ticker} details fetch error: #{reason}")
        reason
    end
  end

  def parse_xml_bond_data(xml_body) do

  end
end