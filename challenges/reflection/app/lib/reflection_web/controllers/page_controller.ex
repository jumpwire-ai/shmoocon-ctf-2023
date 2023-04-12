defmodule ReflectionWeb.PageController do
  use ReflectionWeb, :controller
  alias Reflection.User
  alias Reflection.Guardian

  def index(conn = %{assigns: %{user: %User{}}}, _params) do
    redirect(conn, to: Routes.page_path(conn, :show_user, conn.assigns.user.id))
  end

  def index(conn, _params) do
    redirect(conn, to: Routes.page_path(conn, :login))
  end

  def login(conn, %{"email" => email, "password" => password}) do
    case User.login(email, password) do
      {:ok, user} ->
        authenticate(conn, user)

      _ ->
        conn
        |> put_flash(:error, "Invalid login")
        |> render("login.html")
    end
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def logout(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out")
    |> Guardian.Plug.sign_out()
    |> Guardian.Plug.clear_remember_me()
    |> redirect(to: Routes.page_path(conn, :login))
  end

  def register(conn, %{"user" => params}) do
    case User.create(params) do
      {:ok, user} ->
        authenticate(conn, user)

      {:error, changeset} ->
        render(conn, "register.html", changeset: changeset)
    end
  end

  def register(conn, _params) do
    changeset = Ecto.Changeset.change(%User{})
    render(conn, "register.html", changeset: changeset)
  end


  def show_user(conn, params = %{"id" => id}) do
    user = conn.assigns.user

    if user.id == id or user.is_admin do
      token = generate_token(user, params)
      render(conn, "user.html", token: token)
    else
      body = Jason.encode!(%{message: :insufficient_permissions})
      conn
      |> put_resp_content_type("application/json")
      |> send_resp(401, body)
    end
  end

  defp generate_token(user, params) do
    with {:ok, _} <- Map.fetch(params, "token"),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user) do
      token
    else
      _ -> nil
    end
  end

  defp authenticate(conn, user) do
    conn
    |> Guardian.Plug.sign_in(user)
    |> Guardian.Plug.remember_me(user)
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
