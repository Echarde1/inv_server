defmodule MyInv.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_inv_app,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      #      extra_applications: [:logger, :httpoison, :elixir_xml_to_map],
      extra_applications: [:logger, :elixir_xml_to_map],
      mod: {InvServer.Application, [env: Mix.env]},
      applications: applications(Mix.env)
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:distillery, "~> 2.0"},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},

      {:poison, "~> 4.0"},
      {:plug, "~> 1.7"},
      {:cowboy, "~> 2.5"},
      {:plug_cowboy, "~> 2.0"},

      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:httpoison, "~> 1.6"},

      {:sweet_xml, "~> 0.6.6"},
      {:elixir_xml_to_map, "~> 1.0.1"},
      {:type_struct, "~> 0.1.0"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  defp applications(:dev), do: applications(:default) ++ [:cowboy, :plug]
  defp applications(:test), do: applications(:default) ++ [:cowboy, :plug]
  defp applications(_), do: [:httpoison]
end
