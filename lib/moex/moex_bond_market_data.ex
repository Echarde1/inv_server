defmodule Bonds.MarketData do
  use TypeStruct

  @secid "-SECID"
  @duration "-DURATION"

  defstruct MarketData,
            secid: str, # Идентификатор для мосбиржи
            duration: integer # Дюрация

  def map_market_data(securities_list, market_data_rows), do:
    market_data_rows
    |> Enum.filter(&Map.fetch!(&1, @duration) > 0)
    |> Enum.filter(fn x ->
       market_data_secid = Map.fetch!(x, @secid)
       market_data_secid == Enum.find(securities_list, fn x -> x.secid == market_data_secid end)
    end)
    |> Enum.map(
      fn x ->
        %MarketData{
          secid: Map.fetch!(x, @secid),
          duration: Map.fetch!(x, @duration)
        }
      end
    )

end
