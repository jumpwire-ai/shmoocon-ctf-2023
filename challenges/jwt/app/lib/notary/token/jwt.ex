defmodule Notary.Token.Jwt do
  @behaviour Guardian.Token

  alias Guardian.Token.Jwt
  alias Guardian.Config
  alias Guardian.Token.Jwt.SecretFetcher.SecretFetcherDefaultImpl
  alias JOSE.JWK
  alias JOSE.JWT

  def peek(mod, token) do
    Jwt.peek(mod, token)
  end

  def token_id(), do: Jwt.token_id()

  def create_token(mod, claims, options \\ []) do
    Jwt.create_token(mod, claims, options)
  end

  def build_claims(mod, resource, sub, claims \\ %{}, options \\ []) do
    Jwt.build_claims(mod, resource, sub, claims, options)
  end

  @doc """
  Decodes the token and validates the signature, but ignore it if there
  is no signature.

  Options:
  * `secret` - Override the configured secret. `Guardian.Config.config_value` is valid
  """
  def decode_token(mod, token, options \\ []) do
    with {:ok, secret_fetcher} <- fetch_secret_fetcher(mod),
         %{headers: headers} <- peek(mod, token),
         {:ok, raw_secret} <- secret_fetcher.fetch_verifying_secret(mod, headers, options) do
      secret = jose_jwk(raw_secret)
      verify_result = JWT.verify(secret, token)

      case verify_result do
        {true, jose_jwt, _} -> {:ok, jose_jwt.fields}
        {false, _, _} -> {:error, :invalid_token}
      end
    else
      _ -> {:error, :invalid_token}
    end
  end

  def verify_claims(mod, claims, options) do
    Jwt.verify_claims(mod, claims, options)
  end

  def revoke(mod, claims, token, options) do
    Jwt.revoke(mod, claims, token, options)
  end

  def refresh(mod, old_token, options) do
    Jwt.refresh(mod, old_token, options)
  end

  def exchange(mod, old_token, from_type, to_type, options) do
    Jwt.exchange(mod, old_token, from_type, to_type, options)
  end

  defp fetch_secret_fetcher(mod) do
    {:ok, mod.config(:secret_fetcher, SecretFetcherDefaultImpl)}
  end

  defp jose_jwk(%JWK{} = the_secret), do: the_secret
  defp jose_jwk(the_secret) when is_binary(the_secret), do: JWK.from_oct(the_secret)
  defp jose_jwk(the_secret) when is_map(the_secret), do: JWK.from_map(the_secret)
  defp jose_jwk(value), do: Config.resolve_value(value)
end
