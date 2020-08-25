defmodule InvServer.Application do
  use Application

  def start(_type, args) do
    Supervisor.start_link(children(args), opts())
  end

  defp children(args) do
    case args do
      [env: :prod] -> [Inv.Endpoint]
      [env: :dev] -> [Inv.Endpoint]
      [env: :test] ->
        [
          {
            Plug.Cowboy,
            scheme: :http,
            plug: GithubClient.MockServer,
            options: [
              port: 8081
            ]
          }
        ]
      [_] -> []
    end
  end

  defp opts do
    [
      strategy: :one_for_one,
      name: InvServer.Supervisor
    ]
  end
end
