defmodule Inv.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  @secid "secid"

  get "/" do
    bonds = Inv.Moex.Endpoints.get_moex_bonds()

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(bonds))
  end

#  get "/details/:name" do
#    conn
#    |> put_resp_content_type("application/json")
#    |> send_resp(200, "Здарова, #{name}")
#  end

  get "/details" do
    conn = fetch_query_params(conn)
    %{ @secid => secid } = conn.params

    details = Inv.Moex.Endpoints.get_moex_bond_details(secid)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, Poison.encode!(details))
  end

end
