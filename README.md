# Google Recaptcha

Google Recaptcha API Client for Elixir.

## Installation

  1. Add `google_recaptcha` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:google_recaptcha, "~> 0.1.0"}]
  end
  ```

  2. Run `mix deps.get` to install it.

## Configuration

API keys is needed to get the client working, you can generate [here](https://www.google.com/recaptcha/admin)

And set the keys in your project configuration file:

```elixir
config :google_recaptcha,
  api_url: "https://www.google.com/recaptcha/api/siteverify",
  public_key: "YOUR_PUBLIC_KEY",
  private_key: "YOUR_SECRET_KEY",
  enabled: true # You may set false for development
```

## Documentation

  * https://hexdocs.pm/google_recaptcha/

## Examples

```elixir
GoogleRecaptcha.verify(captcha_response, client_ip_addres)
#captcha_response => g-recaptcha-response POST paramter from captcha widget
```
