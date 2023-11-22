defmodule PleaseRelease.MixProject do
  use Mix.Project

  def project do
    [
      app: :please_release,
      version: "2.8.0",
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
      {:credo, "~> 1.6", only: [:test, :dev], runtime: false},
      {:dialyxir, "~> 1.0", only: [:test, :dev], runtime: false},
      {:earmark, "~> 1.4"},
      {:earmark_reversal, "~> 0.1"},
      {:git_hooks, "~> 0.5", only: [:test, :dev], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:test, :dev], runtime: false}
    ]
  end
end
