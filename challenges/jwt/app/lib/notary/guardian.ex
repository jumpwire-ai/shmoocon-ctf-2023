defmodule Notary.Guardian do
  use Guardian, otp_app: :notary

  def subject_for_token(id, _claims) do
    {:ok, id}
  end

  def resource_from_claims(claims) do
    {:ok, claims}
  end
end
