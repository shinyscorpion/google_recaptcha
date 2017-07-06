defmodule GoogleRecaptcha do
  @moduledoc """
  HTTP client to make requests to Google Recaptcha API.

  API keys is needed to get the client working, you can generate [here](https://www.google.com/recaptcha/admin)

  Then, set the secret env var:

      export RECAPTCHA_SECRET_KEY="34h134oh"

  [Google Recaptcha Docs for more information](https://developers.google.com/recaptcha/docs/verify)
  """
  alias GoogleRecaptcha.Client

  @doc """
  Check in the Recaptcha API if the given captcha response is correct.

  ## Examples

      # Doc how to generate the captcha widget: https://developers.google.com/recaptcha/docs/display#auto_render
      captcha_response = params["g-recaptcha-response"]
      Recaptcha2Client.verify(captcha_response, conn.remote_ip)
      :ok

      Recaptcha2Client.verify("wrong_capcha", conn.remote_ip)
      {:error, :invalid_captcha}

  """
  @spec verify(String.t, String.t | nil) :: :ok | {:error, atom}
  def verify(captcha_response, remote_ip \\ nil) do
    Client.verify(captcha_response, remote_ip)
  end

  @doc"""
  Helper function to check if the captcha is enabled.

  Used for development purpouse, captcha is enabled by default.
  You can change this option overriding the Recaptcha configuration.

      # config/dev.exs
      config :google_recaptcha, enabled: false
  """
  @spec enabled? :: boolean
  def enabled?, do: Application.fetch_env!(:google_recaptcha, :enabled)

  @doc"""
  Public key to be used in google recaptcha widget.

  You can set the public key simply exporting the variabble `RECAPTCHA_PUBLIC_KEY`:

      export RECAPTCHA_PUBLIC_KEY="YOUR_PUBLIC_KEY"

  or overriding the recaptcha config:

      # config/dev.exs
      config :google_recaptcha, public_key: "YOUR_PUBLIC_KEY"

  For more information how to generate/display the recaptcha widget, check [here](https://developers.google.com/recaptcha/docs/display#auto_render).
  """
  @spec public_key :: String.t
  def public_key, do: Application.fetch_env!(:google_recaptcha, :public_key)
end
