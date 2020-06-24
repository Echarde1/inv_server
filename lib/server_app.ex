defmodule InvServer.Application do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(children(), opts())
  end

  defp children do
    [
      Inv.Endpoint
    ]
  end

  defp opts do
    [
      strategy: :one_for_one,
      name: InvServer.Supervisor
    ]
  end
end
