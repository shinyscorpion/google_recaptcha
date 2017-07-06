defmodule GoogleRecaptcha.Mixfile do
  use Mix.Project

  def project do
    [
      app: :google_recaptcha,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),

      # Docs
      name: "Google Recaptcha",
      source_url: "https://github.com/ricardoperez/google_recaptcha",
      docs:
      [
        main: "GoogleRecaptcha",
        extras: ["README.md"],
      ]
    ]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:httpoison, "~> 0.11.0"},
      {:poison, ">= 1.0.0"},

      # dev/test
      {:ex_doc, "~> 0.14", only: :dev, runtime: false},
      {:mock, "~> 0.1.1", only: :test}
    ]
  end
end
