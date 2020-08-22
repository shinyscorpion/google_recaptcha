defmodule GoogleRecaptchaTest do
  use ExUnit.Case, async: false
  alias GoogleRecaptcha.Application, as: App
  import GoogleRecaptcha

  @envs ~w(api_url public_key secret_key enabled timeout retries pool_size)a

  defp start(config) do
    Enum.each(@envs, &:application.unset_env(:google_recaptcha, &1))
    Application.put_all_env(google_recaptcha: config)

    App.start(false, false)

    :ok
  end

  describe "enable: false mode" do
    test "returns `:ok` for verify/2" do
      start(enabled: false)

      assert verify(:fake, :fake) == :ok
    end

    test "returns `true` for valid?/2" do
      start(enabled: false)

      assert valid?(:fake, :fake) == true
    end

    test "returns `false` for enabled?/0" do
      start(enabled: false)

      assert enabled?() == false
    end

    test "returns `\"\"` public_key?/0 if none set" do
      start(enabled: false)

      assert public_key() == ""
    end

    test "returns `set public key for public_key?/0" do
      start(enabled: false, public_key: "bob")
      assert public_key() == "bob"
    end
  end

  describe "errors if enabled: true without proper config" do
    test "missing :public_key" do
      assert_raise RuntimeError, fn -> start(enabled: true, secret_key: "fake") end
    end

    test "missing :secret_key" do
      assert_raise RuntimeError, fn -> start(enabled: true, public_key: "fake") end
    end

    test "missing both :public_key and :secret_key" do
      assert_raise RuntimeError, fn -> start(enabled: true) end
    end
  end

  describe "enable: true mode with proper config" do
    setup do
      start(enabled: true, public_key: "fake", secret_key: "fake")

      :meck.new(:hackney, [:passthrough])
      on_exit(&:meck.unload/0)

      :ok
    end

    test "returns `:ok` for verify/2 if valid" do
      :meck.expect(:hackney, :post, fn "https://www.google.com/recaptcha/api/siteverify",
                                       [],
                                       {:form, [secret: "fake", response: "valid", remoteip: ip]},
                                       [
                                         :with_body,
                                         {:recv_timeout, 10_000},
                                         {:timeout, 10_000},
                                         {:pool, GoogleRecaptcha}
                                       ] ->
        assert ip in [nil, '127.0.0.1']
        {:ok, 200, [], ~S|{"success":true}|}
      end)

      assert verify("valid") == :ok
      assert verify("valid", {127, 0, 0, 1}) == :ok
    end

    test "return `:invalid_request_response` error for JSON decode errors" do
      :meck.expect(:hackney, :post, fn _, _, _, _ -> {:ok, 200, [], ~S|{malformed}|} end)

      assert verify("valid") == {:error, :invalid_request_response}
    end

    test "return `:request_failed` error for hackney (HTTP) errors" do
      :meck.expect(:hackney, :post, fn _, _, _, _ -> {:error, :some_failure} end)

      assert verify("valid") == {:error, :request_failed}
    end

    # https://developers.google.com/recaptcha/docs/verify#error_code_reference
    test "correctly maps Google Captcha Error Codes" do
      codes = %{
        "missing-input-secret" => :missing_secret,
        "invalid-input-secret" => :invalid_secret,
        "missing-input-response" => :missing_captcha,
        "invalid-input-response" => :invalid_captcha,
        "bad-request" => :captcha_request_failed,
        "timeout-or-duplicate" => :captcha_expired,
        "invalid-keys" => :invalid_keys
      }

      Enum.each(codes, fn {code, error} ->
        :meck.expect(:hackney, :post, fn _, _, _, _ ->
          {:ok, 200, [], ~s|{"success":false,"error-codes":["#{code}"]}|}
        end)

        assert verify("valid") == {:error, error}
      end)
    end

    test "return `:unmapped_captcha_error` error for unknown Google Captcha Error code" do
      :meck.expect(:hackney, :post, fn _, _, _, _ ->
        {:ok, 200, [], ~S|{"success":false,"error-codes":[""]}|}
      end)

      assert verify("valid") == {:error, :unmapped_captcha_error}
    end

    test "return `:unknown_captcha_error` error for unknown response data" do
      :meck.expect(:hackney, :post, fn _, _, _, _ -> {:ok, 200, [], ~S|{"weird":true}|} end)

      assert verify("valid") == {:error, :unknown_captcha_error}
    end

    test "returns `true` for valid?/2 with valid token" do
      :meck.expect(:hackney, :post, fn "https://www.google.com/recaptcha/api/siteverify",
                                       [],
                                       {:form, [secret: "fake", response: "valid", remoteip: ip]},
                                       [
                                         :with_body,
                                         {:recv_timeout, 10_000},
                                         {:timeout, 10_000},
                                         {:pool, GoogleRecaptcha}
                                       ] ->
        assert ip in [nil, '127.0.0.1']
        {:ok, 200, [], ~S|{"success":true}|}
      end)

      assert valid?("valid") == true
      assert valid?("valid", {127, 0, 0, 1}) == true
    end

    test "returns `false` for valid?/2 with invalid token" do
      assert valid?("valid") == false
      assert valid?("valid", "192.168.2.1") == false
    end

    test "returns `true` for enabled?/0" do
      assert enabled?() == true
    end

    test "returns the configured key for public_key?/0" do
      assert public_key() == "fake"
    end
  end

  describe "configuration" do
    defp env_start(config, vars, set_base \\ true) do
      test_pid = self()

      on_exit(&:meck.unload/0)
      :meck.new(System, [:passthrough])
      :meck.expect(System, :get_env, fn x -> vars[x] end)

      :meck.new(:hackney, [:passthrough])

      :meck.expect(:hackney, :post, fn url,
                                       [],
                                       {:form, [secret: secret, response: _, remoteip: _]},
                                       [
                                         :with_body,
                                         {:recv_timeout, timeout},
                                         {:timeout, timeout},
                                         {:pool, GoogleRecaptcha}
                                       ] ->
        send(test_pid, {:verify, url, public_key(), secret, timeout})
        {:ok, 200, [], ""}
      end)

      if set_base do
        start(Keyword.merge([enabled: true, public_key: "fake", secret_key: "fake"], config))
      else
        start(config)
      end

      verify("valid")

      receive do
        {:verify, url, key, secret, timeout} ->
          %{url: url, key: key, secret: secret, timeout: timeout}
      end
    end

    test "set timeout with `:timeout` in app config" do
      assert env_start([timeout: 2_000], %{}).timeout == 2_000
    end

    test "set timeout with `RECAPTCHA_TIMEOUT` env var" do
      assert env_start([], %{"RECAPTCHA_TIMEOUT" => "3000"}).timeout == 3_000
    end

    test "set public key with `:public_key` in app config" do
      assert env_start([public_key: "custom"], %{}).key == "custom"
    end

    test "set public key with `RECAPTCHA_PUBLIC_KEY` env var" do
      assert env_start(
               [enabled: true, secret_key: "fake"],
               %{"RECAPTCHA_PUBLIC_KEY" => "custom"},
               false
             ).key == "custom"
    end

    test "set secret key with `:secret_key` in app config" do
      assert env_start([secret_key: "custom"], %{}).secret == "custom"
    end

    test "set secret key with `RECAPTCHA_SECRET_KEY` env var" do
      assert env_start(
               [enabled: true, public_key: "fake"],
               %{"RECAPTCHA_SECRET_KEY" => "custom"},
               false
             ).secret == "custom"
    end
  end
end
