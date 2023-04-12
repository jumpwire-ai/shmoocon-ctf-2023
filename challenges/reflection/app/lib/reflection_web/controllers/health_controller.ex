defmodule ReflectionWeb.HealthController do
  use ReflectionWeb, :controller

  def ping(conn, _) do
    text(conn, "pong")
  end
end
