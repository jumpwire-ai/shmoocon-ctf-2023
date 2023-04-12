import Config

config :penguin,
  flag: "flag{33ceb10be4b910321542f14055c3db7c}",
  key: <<245, 249, 128, 197, 246, 26, 250, 190, 140, 83, 47, 107, 93, 80, 119, 249>>,
  timeout: 300_000

config :penguin, :tcp,
  port: 1337

import_config "#{config_env()}.exs"
