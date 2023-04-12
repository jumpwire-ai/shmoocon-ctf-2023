# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :notary, NotaryWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: NotaryWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Notary.PubSub,
  live_view: [signing_salt: "mFDn5STz"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :notary, :flag, "flag{0278abb4decab30e97cd536bb7ac76a0}"

config :notary, Notary.Guardian,
  issuer: "notary",
  token_module: Notary.Token.Jwt,
  verify_issuer: true,
  secret_key: "xtCNgL4TfXdKBEaHizn+AMJrs5HmECTeS3vnJP1d279puoyjEfchF70rf0aEa48u"

# Enable
config :jose, unsecured_signing: true

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
