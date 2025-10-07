defmodule SmartMapping.MixProject do
  use Mix.Project

  def project do
    [
      app: :smart_mapping,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:solverl, "~> 1.1.0"},
      {:replbug, "~> 0.1.0", only: :dev}
    ]
  end
end
