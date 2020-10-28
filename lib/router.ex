defmodule Inv.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    bonds = Inv.Moex.Endpoints.get_moex_bonds()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(bonds))
  end

end
