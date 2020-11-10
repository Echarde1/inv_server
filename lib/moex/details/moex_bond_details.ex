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
            is_for_qualified: Boolean, # ISQUALIFIEDINVESTORS
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

    %BondDetails{
      secid: Map.fetch!(bond_details_map, "-SECID"),
      name: Map.fetch!(bond_details_map, "-NAME"),
      init_value: Map.fetch!(bond_details_map, "-INITIALFACEVALUE")
                  |> Utils.parse_int,
      currency: Map.fetch!(@currencies_map, Map.fetch!(bond_details_map, "-FACEUNIT")),
      is_early_repayment_available: Map.get(bond_details_map, "-EARLYREPAYMENT", "0")
                                    |> map_int_str_to_bool,
      is_for_qualified: Map.get(bond_details_map, "-ISQUALIFIEDINVESTORS", "0")
                        |> map_int_str_to_bool,
      coupon_frequency: Map.fetch!(bond_details_map, "-COUPONFREQUENCY")
                        |> Utils.parse_int,
      sec_subtype: Map.get(bond_details_map, "-SECSUBTYPE", nil),
      type: type,
      type_name: Map.fetch!(@bonds_types_map, type)
    }
  end

  defp map_int_str_to_bool(int_str) do
    case Utils.parse_int(int_str) do
      1 -> true
      0 -> false
    end
  end

end