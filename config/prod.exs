use Mix.Config

config :my_inv_app, Inv.Endpoint,
       port: "PORT" |> System.get_env() |> String.to_integer()