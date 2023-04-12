defmodule NotaryWeb.Router do
  use NotaryWeb, :router
  use Plug.ErrorHandler

  pipeline :api do
    plug :accepts, ["json"]
    plug Guardian.Plug.Pipeline,
      module: Notary.Guardian,
      error_handler: Notary.AuthErrorHandler
    plug Guardian.Plug.VerifyHeader
  end

  pipeline :authz do
    plug Notary.AuthPipeline
  end

  scope "/", NotaryWeb do
    pipe_through :api
    get "/ping", HealthController, :ping
    get "/register", TokenController, :create
    post "/register", TokenController, :create
  end

  scope "/", NotaryWeb do
    pipe_through [:api, :authz]
    get "/", TokenController, :index
    get "/info", TokenController, :whoami
    get "/secrets/flag", FlagController, :index
  end

  defp handle_errors(conn, %{reason: %Phoenix.Router.NoRouteError{}}) do
    conn |> json(%{error: "No route found"}) |> halt()
  end

  defp handle_errors(conn, _) do
    conn |> json(%{error: "unknown"}) |> halt()
  end
end
