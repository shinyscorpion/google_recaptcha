# Google Recaptcha

Google Recaptcha Client

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `recaptcha_2_client` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:google_recaptcha, "~> 0.1.0"}]
  end
  ```

## Configuration

API keys is needed to get the client working, you can generate [here](https://www.google.com/recaptcha/admin)

Then set the private and public key:

```bash
export RECAPTCHA_PUBLIC_KEY=YOUR_PUBLIC_KEY
export RECAPTCHA_SECRET_KEY=YOUR_SECRET_KEY
``` 

You can also override the configuration in yout `config/config.exs` file: 

```elixir
config :google_recaptcha,
  api_url: "https://www.google.com/recaptcha/api/siteverify",
  public_key: "YOUR_PUBLIC_KEY",
  private_key: "YOUR_SECRET_KEY",
  enabled: true # You may set false for development
```

## Examples

```elixir
GoogleRecaptcha.verify(captcha_response, client_ip_addres)
#captcha_response => g-recaptcha-response POST paramter from captcha widget
```
