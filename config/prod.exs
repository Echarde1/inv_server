use Mix.Config

config :my_inv_app, Inv.Endpoint,
       port: "PORT" |> System.get_env() |> String.to_integer()

config :my_inv_app, moex_base_url: "https://iss.moex.com/iss"