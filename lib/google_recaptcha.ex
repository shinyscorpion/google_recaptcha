defmodule GoogleRecaptcha do
  @moduledoc """
  HTTP client to make requests to Google Recaptcha API.

  API keys is needed to get the client working, you can generate [here](https://www.google.com/recaptcha/admin)

  Then, set the secret env var:

      export RECAPTCHA_SECRET_KEY="34h134oh"

  [Google Recaptcha Docs for more information](https://developers.google.com/recaptcha/docs/verify)
  """

  require Logger

  @open_timeout 10_000
  @recv_timeout 10_000

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
    request_body = [
      secret: recaptcha_secret_key(),
      response: captcha_response,
      remoteip: remote_ip]

    options = [
      ssl: [{:versions, [:'tlsv1.2']}],
      recv_timeout: @recv_timeout,
      timeout: @open_timeout
    ]

    HTTPoison.post!(recaptcha_url(), {:form, request_body}, [], options).body
    |> Poison.decode!
    |> parse_response
  end

  @spec parse_response(map) :: :ok | {:error, atom}
  defp parse_response(%{"success" => true}) do
    :ok
  end

  defp parse_response(%{"success" => false, "error-codes" => errors}) do
    cond do
      Enum.member?(errors, "invalid-input-secret") -> {:error, :invalid_secret}
      Enum.member?(errors, "invalid-input-response") -> {:error, :invalid_captcha}
      Enum.member?(errors, "invalid-keys") -> {:error, :invalid_keys} #public and secret does not match
      true ->
        Logger.info "Recaptcha error: #{inspect errors}"
        {:error, :recaptcha_error}
    end
  end

  @spec recaptcha_url() :: String.t | no_return
  defp recaptcha_url, do: Application.fetch_env!(:google_recaptcha, :api_url)

  @spec recaptcha_secret_key() :: String.t | no_return
  defp recaptcha_secret_key, do: Application.fetch_env!(:google_recaptcha, :api_url)
end
