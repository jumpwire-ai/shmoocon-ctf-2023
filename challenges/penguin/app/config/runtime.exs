import Config

with {:ok, port} <- System.fetch_env("PORT"),
     {port, ""} <- Integer.parse(port) do
  config :penguin, :tcp, port: port
end

with {:ok, timeout} <- System.fetch_env("TIMEOUT_SEC"),
     {timeout, ""} <- Integer.parse(timeout) do
  config :penguin, timeout: timeout * 1000
end
