defmodule ReflectionWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :reflection,
    module: Reflection.Guardian,
    error_handler: ReflectionWeb.AuthErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.LoadResource, allow_blank: true
  plug :assign_user

  defp assign_user(conn, _) do
    case Guardian.Plug.current_resource(conn) do
      nil -> conn
      user -> assign(conn, :user, user) end
  end
end
