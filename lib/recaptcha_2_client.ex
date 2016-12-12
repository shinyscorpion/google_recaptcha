defmodule Recaptcha2Client do
  use Tesla
  @config Application.get_env(:recaptcha_2_client, :config)
  plug Tesla.Middleware.BaseUrl, @config[:captcha_url]

  def verify(captcha_response, remote_ip \\ nil) do
    request_params = %{
      secret: @config[:private_key],
      response: captcha_response,
      remoteip: remote_ip}
    http_response = post(@config[:verify_api], "", query: request_params)
    verify_http_status(http_response)
  end

  defp verify_http_status(http_response = %{status: 200}) do
    verify_captcha_response(Poison.decode!(http_response.body))
  end

  defp verify_http_status(http_response = %{status: _}) do
    {:error, "problem connecting with recaptcha"}
  end

  defp verify_captcha_response(json_body = %{"success" => true}) do
    {:ok, true}
  end

  defp verify_captcha_response(json_body = %{"success" => false, "error-codes" => ["invalid-input-response"] }) do
    {:error, "captcha is wrong"}
  end

  defp verify_captcha_response(json_body = %{"success" => false}) do
    {:error, "captcha timed out"}
  end
end
