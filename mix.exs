defmodule Test.MixProject do
  use Mix.Project

  def project do
    [
      app: :test,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :exprotobuf],
      mod: {Test, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:stargate, git: "https://github.com/vans163/stargate.git"},
      {:exjsx, "~> 4.0.0"},
      {:httpoison, "~> 1.0"},
      {:postgrex, "~> 0.13.3"},
      {:csv, "~> 2.0.0"},
      {:distillery, "~> 2.0"},
      {:exprotobuf, github: "bitwalker/exprotobuf"}
    ]
  end
end
