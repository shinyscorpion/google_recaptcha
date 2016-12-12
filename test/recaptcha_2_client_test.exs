defmodule Recaptcha2ClientTest do
  use ExUnit.Case
  import Mock

  @mock_response_success "{\n  \"success\": true,\n  \"challenge_ts\": \"2016-11-30T15:33:51Z\",\n  \"hostname\": \"localhost\"\n}"
  @mock_response_invalid_captcha "{\n  \"success\": false,\n  \"error-codes\": [\n    \"invalid-input-response\"\n  ]\n}"
  @mock_response_expired_captcha "{\n  \"success\": false,\n  \"challenge_ts\": \"2016-11-30T15:33:51Z\",\n  \"hostname\": \"localhost\"\n}"

  @captcha_response "vB412sTv_mTHgUvUAO_BuNasaPzDFQlebOvQnNWUcy8akRDWlUz"
  @remote_ip "192.168.2.1"

  test "returns true when captcha is right" do
    with_mock Tesla, [perform_request: fn(_params, _options) -> %{body: @mock_response_success, status: 200} end] do
      assert Recaptcha2Client.verify(@captcha_response, @remote_ip) == {:ok, true}
    end
  end

  test "returns error when captcha is wrong" do
    with_mock Tesla, [perform_request: fn(_params, _options) -> %{body: @mock_response_invalid_captcha, status: 200} end] do
      assert Recaptcha2Client.verify(@captcha_response, @remote_ip) == {:error, "captcha is wrong"}
    end
  end

  test "returns error when captcha is expired" do
    with_mock Tesla, [perform_request: fn(_params, _options) -> %{body: @mock_response_expired_captcha, status: 200} end] do
      assert Recaptcha2Client.verify(@captcha_response, @remote_ip) == {:error, "captcha timed out"}
    end
  end

  test "returns error when something goes wrong in recaptcha" do
    with_mock Tesla, [perform_request: fn(_params, _options) -> %{body: "error", status: 500} end] do
      assert Recaptcha2Client.verify(@captcha_response, @remote_ip) == {:error, "problem connecting with recaptcha"}
    end
  end

  test "returns errors when is not a 200 response" do
    with_mock Tesla, [perform_request: fn(_params, _options) -> %{body: "error", status: 400} end] do
      assert Recaptcha2Client.verify(@captcha_response, @remote_ip) == {:error, "problem connecting with recaptcha"}
    end
  end
end
