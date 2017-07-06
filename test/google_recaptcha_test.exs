defmodule GoogleRecaptchaTest do
  use ExUnit.Case, async: false
  import GoogleRecaptcha

  @captcha_response "vB412sTv_mTHgUvUAO_BuNasaPzDFQlebOvQnNWUcy8akRDWlUz"
  @remote_ip "192.168.2.1"

  describe "verify" do
    test "returns :ok when captcha is correct" do
      :meck.expect HTTPoison, :post!, fn(_url, _param, _h, _o) ->
        %{body: Poison.encode!(%{"success" => true, "challenge_ts" => "2017-06-30T15:45:07Z", "hostname" => "localhost"})}
      end

      assert :ok == verify(@captcha_response, @remote_ip)
    end

    test "returns :error when captcha is wrong" do
      :meck.expect HTTPoison, :post!, fn(_url, _param, _h, _o) ->
        %{body: Poison.encode!(%{"success" => false, "error-codes" => ["invalid-input-response"]})}
      end

      assert {:error, :invalid_captcha} == verify(@captcha_response, @remote_ip)
    end

    test "returns :error when secret is invalid" do
      :meck.expect HTTPoison, :post!, fn(_url, _param, _h, _o) ->
        %{body: Poison.encode!(%{"success" => false, "error-codes" => ["invalid-input-secret"]})}
      end

      assert {:error, :invalid_secret} == verify(@captcha_response, @remote_ip)
    end

    test "returns :error when secret does not match public key" do
      :meck.expect HTTPoison, :post!, fn(_url, _param, _h, _o) ->
        %{body: Poison.encode!(%{"success" => false, "error-codes" => ["invalid-keys"]})}
      end

      assert {:error, :invalid_keys} == verify(@captcha_response, @remote_ip)
    end

    test "returns generic :error when recaptcha error is not caught" do
      :meck.expect HTTPoison, :post!, fn(_url, _param, _h, _o) ->
        %{body: Poison.encode!(%{"success" => false, "error-codes" => ["unknown-error"]})}
      end

      assert {:error, :recaptcha_error} == verify(@captcha_response, @remote_ip)
    end
  end
end
