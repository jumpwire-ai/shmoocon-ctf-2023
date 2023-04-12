# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

api_host = "dev.edge.ctf.jumpwire.ai"

config :reflection,
  ecto_repos: [Reflection.Repo],
  flag: "flag{daccdb68a5689144fd56c32c349e92d9}",
  api_host: api_host

config :reflection, Reflection.Repo,
  migration_primary_key: [type: :uuid],
  migration_timestamps: [type: :timestamptz]

# Configures the endpoint
config :reflection, ReflectionWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: ReflectionWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Reflection.PubSub,
  live_view: [signing_salt: "rEdWSJ6F"],
  gzip: false

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.14.29",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :tailwind,
  version: "3.2.4",
  default: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :reflection, Reflection.Guardian,
  allowed_algos: ["HS512"],
  issuer: api_host,
  verify_issuer: true,
  secret_key: "changeme"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
