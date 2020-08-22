defmodule GoogleRecaptcha.Mixfile do
  use Mix.Project

  def project do
    [
      app: :google_recaptcha,
      version: "0.2.0",
      elixir: "~> 1.10",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "Google Recaptcha API Client",

      # Docs
      name: "Google Recaptcha",
      source_url: "https://github.com/shinyscorpion/google_recaptcha",
      docs: [
        main: "GoogleRecaptcha",
        extras: ["README.md"]
      ],

      # Test
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        ignore_warnings: ".dialyzer",
        plt_add_deps: true
      ]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: [
        "Elliott Hilaire",
        "Francesco Grammatico",
        "Ian Luites",
        "Ricardo Perez",
        "Tatsuya Ono"
      ],
      links: %{"GitHub" => "https://github.com/shinyscorpion/google_recaptcha"}
    ]
  end

  def application do
    [applications: [:logger], mod: {GoogleRecaptcha.Application, []}]
  end

  defp deps do
    [
      {:hackney, ">= 0.16.0"},
      {:jason, ">= 1.2.0"},

      # dev/test
      {:analyze, ">= 0.0.0", only: [:dev, :test], runtime: false, override: true},
      {:meck, "~> 0.9", only: :test}
    ]
  end
end
