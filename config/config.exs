use Mix.Config

config :my_inv_app, Inv.Repo,
  database: "my_inv_app_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :my_inv_app, Inv.Endpoint, port: 4000

import_config "#{Mix.env()}.exs"