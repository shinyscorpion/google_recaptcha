defmodule GoogleRecaptcha.Mixfile do
  use Mix.Project

  def project do
    [
      app: :google_recaptcha,
      version: "0.1.5",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      description: "Google Recaptcha API Client",

      # Docs
      name: "Google Recaptcha",
      source_url: "https://github.com/shinyscorpion/google_recaptcha",
      docs:
      [
        main: "GoogleRecaptcha",
        extras: ["README.md"],
      ],

      # Test
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        "coveralls": :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        ignore_warnings: "dialyzer.ignore-warnings",
        plt_add_deps: true
      ]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      maintainers: ["Elliott Hilaire", "Francesco Grammatico", "Ian Luites", "Ricardo Perez", "Tatsuya Ono"],
      links: %{"GitHub" => "https://github.com/shinyscorpion/google_recaptcha"}
    ]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [
      {:httpoison, ">= 0.12.0"},
      {:poison, ">= 1.0.0"},

      # dev/test
      {:analyze, ">= 0.0.0", only: [:dev, :test], runtime: false, override: true},
      {:meck, "~> 0.8", only: :test},
    ]
  end
end
