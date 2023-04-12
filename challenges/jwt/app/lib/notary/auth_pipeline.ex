defmodule Notary.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :notary,
    module: Notary.Guardian,
    error_handler: Notary.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
end
