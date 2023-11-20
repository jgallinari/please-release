defmodule PleaseRelease.MixProject do
  use Mix.Project

  def project do
    [
      app: :release_please,
      version: "2.2.0",
      elixir: "~> 1.14",
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
      {:earmark, "~> 1.4"},
      {:earmark_reversal, "~> 0.1"}
    ]
  end
end
