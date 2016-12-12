use Mix.Config

config :recaptcha_2_client, config: %{
  captcha_url: System.get_env("RECAPTCHA_URL") || "https://www.google.com/recaptcha",
  api_path: System.get_env("RECAPTCHA_API_PATH") || "/api/siteverify",
  public_key: System.get_env("RECAPTCHA_PUBLIC_KEY"),
  private_key: System.get_env("RECAPTCHA_SECRET_KEY") }


