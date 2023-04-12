defmodule Reflection.Repo do
  use Ecto.Repo,
    otp_app: :reflection,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    config =
      with {:ok, true} <- Keyword.fetch(config, :ssl),
           {:ok, host} <- Keyword.fetch(config, :hostname) do
        ssl_opts = [
          verify: :verify_peer,
          cacertfile: CAStore.file_path(),
          server_name_indication: String.to_charlist(host),
          customize_hostname_check: [match_fun: :public_key.pkix_verify_hostname_match_fun(:https)],
        ]
        Keyword.put(config, :ssl_opts, ssl_opts)
      else
        _ -> config
      end

    {:ok, config}
  end
end
