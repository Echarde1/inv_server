defmodule Inv.Endpoint do
  use Plug.Router
  require Logger

  plug(:match)

  plug(
    Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  forward("/bonds", to: Inv.Router)

  match _ do
    send_resp(conn, 404, "Requested page not found!")
  end

  def init(_) do
    IO.puts("Inting Inv.Endpoints")
    Inv.Repo.start()
  end

  def child_spec(opts) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  def start_link(_opts) do
    IO.puts("Starting Inv.Endpoints")

    with {:ok, [port: port] = config} <- Application.fetch_env(:my_inv_app, __MODULE__) do
      Logger.info("Starting server at http://localhost:#{port}/")
      Plug.Cowboy.http(__MODULE__, [], config)
    end
  end
end
