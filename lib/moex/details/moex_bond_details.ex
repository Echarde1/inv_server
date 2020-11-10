defmodule Bonds.Details do
  use TypeStruct

  @currencies_map %{
    "SUR" => "RUB",
    "USD" => "USD"
  }

  @bonds_types_map %{
    "exchange_bond" => "Биржевая облигация",
    "corporate_bond" => "Корпоративная облигация",
    "municipal_bond" => "Муниципальная облигация",
    "subfederal_bond" => "Региональная облигация",
    "ofz_bond" => "ОФЗ",
    "euro_bond" => "Еврооблигация"
  }

  defstruct BondDetails,
            secid: str, # SECID
            name: str, # NAME
            init_value: float, # INITIALFACEVALUE Первоначальная номинальная стоимость
            currency: str, # FACEUNIT
            is_early_repayment_available: Boolean, # EARLYREPAYMENT
            coupon_frequency: integer, # COUPONFREQUENCY Периодичность выплаты купона в год
            sec_subtype: str, # SECSUBTYPE Подтип облигации Облигации с ипотечным покрытием. Может отсутствовать
            type: str, # TYPE Вид/категория ценной бумаги Пр. ofz_bond
            type_name: str # TYPENAME Описание Вида/категории ценной бумаги Пр. Корпоративная облигация

  def map_security_details(bond_data_arr) do
    bond_details_map = Map.new(
      bond_data_arr,
      fn x ->
        key = "-#{Map.fetch!(x, "-name")}"
        value = Map.fetch!(x, "-value")

        {key, value}
      end
    )

    type = Map.fetch!(bond_details_map, "-TYPE")
    currency = Map.fetch!(
      @currencies_map,
      Map.fetch!(bond_details_map, "-FACEUNIT")
    )

    IO.inspect(currency)

    %BondDetails{
      secid: Map.fetch!(bond_details_map, "-SECID"),
      name: Map.fetch!(bond_details_map, "-NAME"),
      init_value: Map.fetch!(bond_details_map, "-INITIALFACEVALUE")
                  |> Utils.parse_int,
      currency: currency,
      is_early_repayment_available: Map.fetch!(bond_details_map, "-EARLYREPAYMENT")
                                    |> Utils.parse_int
                                    |> map_early_payment_availability,
      coupon_frequency: Map.fetch!(bond_details_map, "-COUPONFREQUENCY")
                        |> Utils.parse_int,
      sec_subtype: map_bond_subtype(bond_details_map),
      type: type,
      type_name: Map.fetch!(@bonds_types_map, type)
    }
  end

  defp map_early_payment_availability(integer) do
    case integer do
      1 -> true
      0 -> false
    end
  end

  defp map_bond_subtype(bond) do
    case Map.fetch(bond, "-SECSUBTYPE") do
      {:ok, value} -> value
      :error -> nil
    end
  end

end