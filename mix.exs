defmodule Eventful.MixProject do
  @moduledoc false
  use Mix.Project

  @version "3.2.2"

  def project do
    [
      app: :eventful,
      version: @version,
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      docs: docs(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      description: "Provide Event tracking for your Ecto Model",
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Zack Siri"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/zacksiri/eventful"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [test: ["ecto.create --quiet", "ecto.migrate", "test"]]
  end

  defp docs do
    [
      source_ref: "#{@version}",
      main: "getting-started",
      extra_section: "GUIDES",
      extras: extras(),
      groups_for_extras: groups_for_extras()
    ]
  end

  defp extras do
    [
      "guides/introduction/getting-started.md",
      "guides/introduction/triggers.md",
      "guides/introduction/guards.md"
    ]
  end

  defp groups_for_extras do
    [
      Introduction: ~r/guides\/introduction\/.?/
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.0"},
      {:jason, "~> 1.0"},
      {:postgrex, "~> 0.14", only: :test},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
