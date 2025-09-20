defmodule DbSubscriptor.MixProject do
  use Mix.Project

  def project do
    [
      app: :dbreplex,
      version: "0.1.0",
      start_permanent: Mix.env() == :prod,
      name: "DBReplex",
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {DBReplex, []}
    ]
  end

  # Dependencies listed here are available only for this
  # project and cannot be accessed from applications inside
  # the apps folder.
  #
  # Run "mix help deps" for examples and options.
  defp deps do
    [
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:postgrex, "~> 0.20.0"}
    ]
  end
end
