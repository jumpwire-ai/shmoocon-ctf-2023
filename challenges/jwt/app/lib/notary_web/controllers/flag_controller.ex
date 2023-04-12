defmodule NotaryWeb.FlagController do
  use NotaryWeb, :controller

  def index(conn, _) do
    case Guardian.Plug.current_claims(conn) do
      %{"https://ctf.jumpwire.ai/admin" => true} ->
        data = %{"flag" => Application.get_env(:notary, :flag)}
        json(conn, data)

      _ ->
        body = Jason.encode!(%{message: "Ah ah ah! You didn't say the magic word!"})
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:forbidden, body)
    end
  end
end
