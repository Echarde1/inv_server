defmodule Inv.Moex.Bond do
  use TypeStruct

  @list_level "-LISTLEVEL"
  @prev_close_price "-PREVLEGALCLOSEPRICE"
  @coupon_percent "-COUPONPERCENT"
  @lowest_list_level 2

  defmodule Cache do
    use GenServer

    def new() do
      {:ok, pid} = GenServer.start_link(__MODULE__, [])
      pid
    end

    @impl GenServer
    def init(list) do
      {:ok, list}
    end

    def add_entry(pid, entry) do
      GenServer.cast(pid, {:add, entry})
    end

    def get_entries(pid) do
      GenServer.call(pid, :get)
    end

    @impl GenServer
    def handle_cast({:add, entry}, list) do
      new_list = [entry | list]
      {:noreply, new_list}
    end

    @impl GenServer
    def handle_call(:get, _, list), do: {:reply, list, list}

  end

  defstruct Bond,
            secid: str,
              # Идентификатор для мосбиржи
            isin: str,
              # Общий идентификатор облигации
            sec_name: str,
            maturity_date: Date,
              #Дата погашения
            prev_close_price: float,
            list_level: integer,
            coupon_percent: float,
              # Ставка купона
            accumulated_coupon_income: float # НКД

  def parse_xml_bonds_list(xml_doc) do
    xml_doc
    |> get_rows_list
    |> Enum.filter(
         # Фильтруем пустые данные. Имеются дубли с заполненными данными
         &Utils.is_not_empty_string(
           Map.fetch!(&1, @prev_close_price)
         )
       )
    |> filter_prev_close_price
      #    |> filter_list_level
      #    |> Enum.take(1)
    |> map_raw_bond
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

  defp filter_prev_close_price(bonds_list) do
    cache_pid = Cache.new()
    try do
      #      result = bonds_list
      bonds_list
      |> Enum.filter(
           fn x ->
             predicate = fn (price) ->
               Utils.is_not_empty_string(price) && Utils.parse_float(price) >= 0
             end
             Map.fetch!(x, @prev_close_price)
           end
         )
      #               |> Enum.filter(
      #                    fn x ->
      #                      Cache.add_entry(cache_pid, x)
      #                      price = Map.fetch!(x, @prev_close_price)
      #                      is_not_empty_str = Utils.is_not_empty_string(price)
      #                      IO.inspect(is_not_empty_str)
      #                      is_not_empty_str || Utils.parse_float(price) >= 0
      #                    end
      #                  )

      #      %{:r => result, :c => Cache.get_entries(cache_pid)}
      #      result
    rescue
      e in FunctionClauseError ->
        IO.inspect(Cache.get_entries(cache_pid))
        raise(e)
    end
  end

  defp filter_list_level(bonds_list, level \\ @lowest_list_level), do:
    bonds_list
    |> Enum.filter(
         &Map.fetch!(&1, @list_level)
          |> Utils.parse_int <= level
       )

  defp filter_coupon_percent(bonds_list, percent \\ 0), do:
    bonds_list
    |> Enum.filter(
         &Map.fetch!(&1, @coupon_percent)
          |> Utils.parse_float >= percent
       )

  defp map_raw_bond(bonds_list) do
    IO.inspect(bonds_list)

    Enum.map(
      bonds_list,
      fn x ->
        %Bond{
          secid: Map.fetch!(x, "-SECID"),
          isin: Map.fetch!(x, "-ISIN"),
          sec_name: Map.fetch!(x, "-SECNAME"),
          maturity_date: Map.fetch!(x, "-MATDATE"),
          prev_close_price: Map.fetch!(x, @prev_close_price)
                            |> Utils.parse_float,
          list_level: Map.fetch!(x, @list_level)
                      |> Utils.parse_int,
          coupon_percent: Map.fetch!(x, @coupon_percent),
          accumulated_coupon_income: Map.fetch!(x, "-ACCRUEDINT")
        }
      end
    )
  end
end
