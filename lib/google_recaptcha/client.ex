defmodule GoogleRecaptcha.Client do
  @moduledoc false

  @open_timeout 10_000
  @recv_timeout 10_000

  require Logger

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
      Enum.member?(errors, "invalid-keys") -> {:error, :invalid_keys}
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
