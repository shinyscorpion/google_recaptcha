defmodule GoogleRecaptcha.Application do
  @moduledoc false
  use Application
  require Logger

  @local_enabled Mix.env() != :test
  @affirmative [true, "true", "1", "yes", "y"]

  @doc false
  @spec start(Application.start_type(), term) :: {:ok, pid}
  def start(_type, _args) do
    api_url =
      config(:api_url, "RECAPTCHA_API_URL", "https://www.google.com/recaptcha/api/siteverify")

    public_key = config(:public_key, "RECAPTCHA_PUBLIC_KEY")
    secret_key = config(:secret_key, "RECAPTCHA_SECRET_KEY")
    enabled? = config(:enabled, "RECAPTCHA_ENABLED", @local_enabled) in @affirmative

    {verify, enabled, get_public_key} = generate(api_url, public_key, secret_key, enabled?)

    Code.compiler_options(ignore_module_conflict: true)

    Code.compile_quoted(
      quote do
        defmodule GoogleRecaptcha.Client do
          @moduledoc false

          @doc false
          @spec verify(String.t(), :inet.ip_address() | String.t() | nil) :: :ok | {:error, atom}
          def verify(captcha_response, remote_ip)
          unquote(verify)

          @doc false
          @spec enabled? :: boolean
          def enabled?
          unquote(enabled)

          @doc false
          @spec public_key :: String.t()
          def public_key
          unquote(get_public_key)
        end
      end
    )

    Code.compiler_options(ignore_module_conflict: false)

    {:ok, self()}
  end

  @spec stop(Application.state()) :: term()

  @spec generate(
          api_url :: String.t(),
          public_key :: String.t(),
          secret_key :: String.t(),
          enabled? :: boolean
        ) :: {term, term, term} | no_return
  defp generate(api_url, public_key, secret_key, enabled?)

  defp generate(_, public_key, _, _enabled? = false) do
    Logger.info("GoogleRecaptcha: Disabled")

    {quote do
       def verify(_, _), do: :ok
     end,
     quote do
       def enabled?, do: false
     end,
     quote do
       def public_key, do: unquote(public_key || "")
     end}
  end

  defp generate(_, nil, _, _enabled? = true) do
    msg = """
    GoogleRecaptcha: Can not start GoogleRecaptcha since no public key was set.

      Please set a public key using:
        - config `config :google_recaptcha, public_key: "..."`.
        - the "RECAPTCHA_PUBLIC_KEY" environment variable.

      Or disable GoogleRecaptcha by setting:
        - config `config :google_recaptcha, enabled: false`.
        - the "RECAPTCHA_ENABLED" environment variable to "false".
    """

    Logger.error(msg)
    raise msg
  end

  defp generate(_, _, nil, _enabled? = true) do
    msg = """
    GoogleRecaptcha: Can not start GoogleRecaptcha since no secret key was set.

      Please set a secret key using:
        - config `config :google_recaptcha, secret_key: "..."`.
        - the "RECAPTCHA_SECRET_KEY" environment variable.

      Or disable GoogleRecaptcha by setting:
        - config `config :google_recaptcha, enabled: false`.
        - the "RECAPTCHA_ENABLED" environment variable to "false".
    """

    Logger.error(msg)
    raise msg
  end

  # credo:disable-for-next-line
  defp generate(api_url, public_key, secret_key, _enabled? = true) do
    Logger.info("GoogleRecaptcha: Enabled")

    # Configure Hackney
    {:ok, _} = :application.ensure_all_started(:hackney)

    timeout = :timeout |> config("RECAPTCHA_TIMEOUT", 10_000) |> integer!()
    retries = :retries |> config("RECAPTCHA_RETRIES", 5) |> integer!()
    pool_size = :pool_size |> config("RECAPTCHA_POOL_SIZE", 100) |> integer!()
    pool_timeout = :pool_size |> config("RECAPTCHA_POOL_TIMEOUT", 150_000) |> integer!()

    :hackney_pool.start_pool(GoogleRecaptcha.Client,
      max_connections: pool_size,
      timeout: pool_timeout
    )

    {quote do
       def verify(captcha_response, remote_ip) do
         ip = if(is_tuple(remote_ip), do: :inet.ntoa(remote_ip), else: remote_ip)

         body =
           {:form,
            [
              secret: unquote(secret_key),
              response: captcha_response,
              remoteip: ip
            ]}

         with {:ok, data} <-
                try_post(body,
                  recv_timeout: unquote(timeout),
                  timeout: unquote(timeout),
                  pool: GoogleRecaptcha
                ) do
           case Jason.decode(data) do
             {:ok, parsed} -> parse_response(parsed)
             _ -> {:error, :invalid_request_response}
           end
         end
       end

       @spec try_post(body :: binary, settings :: Keyword.t(), attempts :: non_neg_integer) ::
               {:ok, data :: binary} | {:error, :request_failed}
       defp try_post(body, settings, attempts \\ 0) do
         case :hackney.post(unquote(api_url), [], body, [
                :with_body | settings
              ]) do
           {:ok, _status, _headers, data} ->
             {:ok, data}

           err ->
             if attempts > unquote(retries) do
               require Logger

               Logger.warn(fn -> "GoogleRecaptcha: Request Failed: #{inspect(err)}" end,
                 error: err
               )

               {:error, :request_failed}
             else
               try_post(body, settings, attempts + 1)
             end
         end
       end

       @spec parse_response(map) ::
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
                  | :unknown_captcha_error}
       defp parse_response(%{"success" => true}), do: :ok

       # https://developers.google.com/recaptcha/docs/verify#error_code_reference
       defp parse_response(%{"error-codes" => x = [c | _]}) do
         case c do
           "missing-input-secret" -> {:error, :missing_secret}
           "invalid-input-secret" -> {:error, :invalid_secret}
           "missing-input-response" -> {:error, :missing_captcha}
           "invalid-input-response" -> {:error, :invalid_captcha}
           "bad-request" -> {:error, :captcha_request_failed}
           "timeout-or-duplicate" -> {:error, :captcha_expired}
           "invalid-keys" -> {:error, :invalid_keys}
           _ -> {:error, :unmapped_captcha_error}
         end
       end

       defp parse_response(_), do: {:error, :unknown_captcha_error}
     end,
     quote do
       def enabled?, do: true
     end,
     quote do
       def public_key, do: unquote(public_key)
     end}
  end

  @spec integer!(term) :: integer | no_return
  defp integer!(value)
  defp integer!(value) when is_integer(value), do: value
  defp integer!(value) when is_binary(value), do: String.to_integer(value)

  @spec config(atom, String.t(), term) :: term
  defp config(key, env, default \\ nil) do
    case Application.fetch_env(:google_recaptcha, key) do
      {:ok, v} -> v
      :error -> System.get_env(env) || default
    end
  end
end
