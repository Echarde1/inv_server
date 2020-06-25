use Mix.Config

config :my_inv_app, Inv.Endpoint, port: 4000

import_config "#{Mix.env()}.exs"