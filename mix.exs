defmodule AshJoinBug.MixProject do
  use Mix.Project

  def project do
    [
      app: :ash_join_bug,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AshJoinBug.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # AshMysql depends on master, locked to this specific ecto/ecto_sql revision.
      # In order to make both data layers happy, we have to override it here.
      {:ecto,
       git: "https://github.com/elixir-ecto/ecto.git",
       ref: "e2ece90d98644a142d3c419b178dc9296a750a34",
       override: true},
      {:ecto_sql,
       git: "https://github.com/elixir-ecto/ecto_sql.git",
       ref: "f5d29e30d875b5a8f6ab303e51223384467c83a3",
       override: true},
      {:ash, "~> 3.2.0"},
      {:ash_postgres, "~> 2.0"},
      {:ash_mysql, github: "ash-project/ash_mysql"}
    ]
  end
end
