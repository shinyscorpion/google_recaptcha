# Google Recaptcha

[![Hex.pm](https://img.shields.io/hexpm/v/google_recaptcha.svg "Hex")](https://hex.pm/packages/google_recaptcha)
[![Build Status](https://travis-ci.org/shinyscorpion/google_recaptcha.svg?branch=master)](https://travis-ci.org/shinyscorpion/google_recaptcha)
[![Inline docs](http://inch-ci.org/github/shinyscorpion/google_recaptcha.svg?branch=master)](http://inch-ci.org/github/shinyscorpion/google_recaptcha)

Google Recaptcha API Client for Elixir.

## Installation

  1. Add `google_recaptcha` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [{:google_recaptcha, "~> 0.2.0"}]
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
  secret_key: "YOUR_SECRET_KEY",
  enabled: true # You may set false for development
```

## Documentation

  * https://hexdocs.pm/google_recaptcha/

## Usage

Check if the captcha is valid, returns `:ok` when it is valid and `{:error, :error_type}` when something goes wrong:

```elixir
# When captcha is valid
iex> GoogleRecaptcha.verify(captcha_response, client_ip_addres)
...> :ok

iex> GoogleRecaptcha.verify(captcha_response, client_ip_addres)
...> {:error, :invalid_captcha}
```

Check if the captcha is valid(check if the recaptcha is enabled), in this case returns bolean(any error will be return as `false`):

```elixir
# When captcha is valid
iex> GoogleRecaptcha.valid?(captcha_response, client_ip_addres)
...> true

# When captcha is disabled
iex> GoogleRecaptcha.valid?(captcha_response, client_ip_addres)
...> true

# Wrong captcha response
iex> GoogleRecaptcha.valid?(wrong_captcha_response, client_ip_addres)
...> false
```
