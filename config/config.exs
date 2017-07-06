use Mix.Config

config :google_recaptcha,
  api_url: "https://www.google.com/recaptcha/api/siteverify",
  public_key: System.get_env("RECAPTCHA_PUBLIC_KEY"),
  private_key: System.get_env("RECAPTCHA_SECRET_KEY"),
  enabled: System.get_env("RECAPTCHA_ENABLED") || true
