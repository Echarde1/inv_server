defmodule Inv.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(message()))
  end

  defp message do
    %{
      response_type: "in_channel",
      text: "Привет от Даньки!! Скоро он научит меня выгружать данные по облигациям и отправлять их в табличку"
    }
  end
end
