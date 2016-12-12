# Recaptcha2Client

Simple Recaptcha Client

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `recaptcha_2_client` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:recaptcha_2_client, "~> 0.1.0"}]
    end
    ```

  2. Ensure `recaptcha_2_client` is started before your application:

    ```elixir
    def application do
      [applications: [:recaptcha_2_client]]
    end
    ```

## Configuration

Set the private and public key

    ```
    export RECAPTCHA_PUBLIC_KEY=YOUR_PUBLIC_KEY
    export RECAPTCHA_SECRET_KEY=YOUR_SECRET_KEY
    ```

## Usage

  ```elixir
  Recaptcha2Client.verify(captcha_response, client_ip_addres)
  #captcha_response => g-recaptcha-response POST paramter from captcha widget
  ```

### TODO

* Display Recaptcha widget
