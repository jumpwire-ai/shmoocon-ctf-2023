defmodule NotaryWeb.TokenController do
  use NotaryWeb, :controller

  def index(conn, _) do
    data = %{
      "message" => "Welcome to the Mugjournal API server! We are excited to have you here. Mugjournal is a leading provider of innovative solutions for businesses and developers, and our API is a key part of that. Whether you are a developer looking to build a new application or a business looking to automate processes, our API has something to offer. With our easy-to-use documentation and top-notch support team, you'll have everything you need to get started. Thank you for choosing Mugjournal, and we hope you have a great experience using our API.",
    }
    json(conn, data)
  end

  def create(conn, %{"name" => name, "email" => email}) do
    id = UUID.uuid4()

    claims = %{
      "https://ctf.jumpwire.ai/admin" => false,
      "name" => name,
      "email" => email,
    }

    {:ok, token, _claims} = Notary.Guardian.encode_and_sign(id, claims)
    data = %{"token" => token, "id" => id}

    json(conn, data)
  end

  def create(conn, _) do
    conn
    |> put_status(402)
    |> json(%{"error" => "name and email are required to register"})
  end

  def whoami(conn, _params) do
    case Guardian.Plug.current_claims(conn) do
      nil -> json(conn, %{})
      data -> json(conn, data)
    end
  end
end
