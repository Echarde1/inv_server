defmodule Inv.Endpoint do
  use Plug.Router

  plug(:match)

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/bot", to: Inv.Router)

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  require Logger

  def start_link(_opts) do
    Logger.info("Starting server at http://localhost:4000/")
    Plug.Cowboy.http(__MODULE__, [])
  end

end
