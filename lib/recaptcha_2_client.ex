defmodule Recaptcha2Client do
  use Tesla
  @config Application.get_env(:recaptcha_2_client, :config)
  plug Tesla.Middleware.BaseUrl, @config[:captcha_url]

  @doc """
    Check in the Recaptcha API if the given captcha response is correct

    ```
    # Example using with phoenix
    captcha_response = params["g-recaptcha-response"]
    Recaptcha2Client.verify(captcha_response, conn.remote_ip)
    ```
  """
  @spec verify(String.t, String.t) :: {:ok, true} | {:error, String.t}
  def verify(captcha_response, remote_ip \\ nil) do
    request_params = %{
      secret: @config[:private_key],
      response: captcha_response,
      remoteip: remote_ip}
    http_response = post(@config[:verify_api], "", query: request_params)
    verify_http_status(http_response)
  end

  @spec verify_http_status(struct()) :: {:ok, true} | {:error, String.t}
  defp verify_http_status(http_response = %{status: 200}) do
    verify_captcha_response(Poison.decode!(http_response.body))
  end

  defp verify_http_status(%{status: _}) do
    {:error, "problem connecting with recaptcha"}
  end

  defp verify_captcha_response(%{"success" => true}) do
    {:ok, true}
  end

  defp verify_captcha_response(%{"success" => false, "error-codes" => ["invalid-input-response"] }) do
    {:error, "captcha is wrong"}
  end

  defp verify_captcha_response(%{"success" => false}) do
    {:error, "captcha timed out"}
  end
end
