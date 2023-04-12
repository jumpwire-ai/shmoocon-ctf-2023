defmodule ReflectionWeb.Router do
  use ReflectionWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {ReflectionWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ReflectionWeb.AuthPipeline
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug ReflectionWeb.AuthPipeline
  end

  pipeline :authz do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/", ReflectionWeb, host: Application.compile_env!(:reflection, :api_host) do
    pipe_through [:api, :authz]

    get "/", ApiController, :index
  end

  scope "/", ReflectionWeb do
    pipe_through :browser

    get "/", PageController, :index

    get "/login", PageController, :login
    post "/login", PageController, :login
    get "/logout", PageController, :logout

    get "/register", PageController, :register
    post "/register", PageController, :register
  end

  scope "/", ReflectionWeb do
    pipe_through [:browser, :authz]

    get "/user/:id", PageController, :show_user
    put "/user/:id", PageController, :show_user
  end

  scope "/", ReflectionWeb do
    pipe_through :api
    get "/ping", HealthController, :ping
  end
end
