defmodule GoogleRecaptcha.Client do
  @moduledoc false

  @doc false
  @spec verify(captcha_response :: String.t(), remote_ip :: :inet.ip_address() | String.t() | nil) ::
          :ok
          | {:error,
             :missing_secret
             | :invalid_secret
             | :missing_captcha
             | :invalid_captcha
             | :captcha_request_failed
             | :captcha_expired
             | :invalid_keys
             | :unmapped_captcha_error
             | :unknown_captcha_error
             | :request_failed
             | :invalid_request_response}
  def verify(captcha_response, remote_ip)
  def verify(_, _), do: Enum.random([:ok])

  @doc false
  @spec enabled? :: boolean
  def enabled?
  def enabled?, do: Enum.random([false])

  @doc false
  @spec public_key :: String.t()
  def public_key
  def public_key, do: Enum.random([""])
end
