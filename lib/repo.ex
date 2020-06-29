defmodule Inv.Repo do
  use GenServer
  use Ecto.Repo,
      otp_app: :my_inv_app,
      adapter: Ecto.Adapters.Postgres

  def start do
    IO.puts("Starting Inv.Repo")
    GenServer.start(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    IO.puts("Initing Inv.Repo")
  end
end
