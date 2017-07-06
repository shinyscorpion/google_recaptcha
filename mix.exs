defmodule GoogleRecaptcha.Mixfile do
  use Mix.Project

  def project do
    [app: :google_recaptcha,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:tesla, "~> 0.5"},
     {:poison, ">= 1.0.0"},
     {:mock, "~> 0.1.1", only: :test}]
  end
end
