# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :wolf_rabbit_carrot,
  ecto_repos: [WolfRabbitCarrot.Repo]

# Configures the endpoint
config :wolf_rabbit_carrot, WolfRabbitCarrotWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bzneTZcbdL/OAbMCGtTNSmcBr6ph7ZiPq5ohFZLh9PxjLWMt4woW2S4yXUimMcBo",
  render_errors: [view: WolfRabbitCarrotWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: WolfRabbitCarrot.PubSub,
  live_view: [signing_salt: "LJa4FC//"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
