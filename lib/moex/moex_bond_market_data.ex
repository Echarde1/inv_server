defmodule Bonds.MarketData do
  use TypeStruct

  @secid "-SECID"
  @duration "-DURATION"

  defstruct MarketData,
            secid: str,
              # Идентификатор для мосбиржи
            duration: integer # Дюрация

  def map_market_data(securities_list, market_data_rows) do
    cache_pid = Cache.Set.new()

    market_data_rows
    |> filter_zero_duration
    |> Utils.build_secid_duplicates_set(cache_pid)
    #    |> Enum.filter(fn x ->
    #       market_data_secid = Map.fetch!(x, @secid)
    #       market_data_secid == Enum.find(securities_list, fn x -> x.secid == market_data_secid end)
    #    end)
    #    |> Enum.map(
    #      fn x ->
    #        %MarketData{
    #          secid: Map.fetch!(x, @secid),
    #          duration: Map.fetch!(x, @duration)
    #        }
    #      end
    #    )
  end

  defp filter_zero_duration(market_data_rows), do:
    market_data_rows
    |> Enum.filter(
         &Map.fetch!(&1, @duration)
          |> Utils.parse_int > 0
       )

end
