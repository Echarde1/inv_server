defmodule Inv.Moex.Endpoints do
  require Logger

  @base_url Application.get_env(:my_inv_app, :moex_base_url)

  def get_moex_bonds() do
    case HTTPoison.get(@base_url <> "engines/stock/markets/bonds/securities.xml") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.info("Moex bonds list body: #{body}")
        Inv.Moex.parse_xml_bond_details_data(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error("Moex bonds list fetch page not found")
        "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Moex bonds list fetch error")
        reason
    end
  end

  def get_moex_bond_details(ticker) do
    case HTTPoison.get(@base_url <> "/securities/#{ticker}") do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Logger.info("Moex bond with ticker #{ticker} info body: #{body}")
        Inv.Moex.parse_xml_bond_details_data(body)
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Logger.error("Moex bond with ticker #{ticker} details fetch page not found")
        "Not found :("
      {:error, %HTTPoison.Error{reason: reason}} ->
        Logger.error("Moex bond with ticker #{ticker} details fetch error: #{reason}")
        reason
    end
  end
end