defmodule NotaryWeb.HealthController do
  use NotaryWeb, :controller

  def ping(conn, _) do
    text(conn, "pong")
  end
end
