defmodule Bonds.ListMarketData do
  use TypeStruct

  @secid "-SECID"
  @duration "-DURATION"

  defstruct MarketData,
            secid: str, # Идентификатор для мосбиржи
            duration: integer # Дюрация

  def map_market_data(market_data_rows, securities) do
    securities_secid_set = MapSet.new(securities, fn x -> x.secid end)

    market_data_rows
    |> Enum.filter(
         fn x ->
           secid = Map.fetch!(x, @secid)
           MapSet.member?(securities_secid_set, secid)
         end
       )
    |> filter_zero_duration
    |> Enum.map(
         fn x ->
           %MarketData{
             secid: Map.fetch!(x, @secid),
             duration: Map.fetch!(x, @duration)
                       |> Utils.parse_int
           }
         end
       )
  end

  defp filter_zero_duration(market_data_rows) do
    default_duration_str = "0"

    market_data_rows
    |> Enum.filter(
         &Map.get(&1, @duration, default_duration_str)
          |> Utils.parse_int > 0
       )
  end

end
