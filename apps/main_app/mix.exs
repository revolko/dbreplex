defmodule MainApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :main_app,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MainApp, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Core
      {:core, in_umbrella: true},

      # Subscribers
      {:pg_subscriber, in_umbrella: true},

      # Publishers
      {:file_publisher, in_umbrella: true}
    ]
  end
end
