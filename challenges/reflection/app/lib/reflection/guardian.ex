defmodule Reflection.Guardian do
  use Guardian, otp_app: :reflection
  alias Reflection.User

  @impl Guardian
  def subject_for_token(%User{id: id}, _claims) do
    {:ok, id}
  end

  @impl Guardian
  def subject_for_token(_resource, _claims) do
    {:error, :missing_subject}
  end

  @impl Guardian
  def resource_from_claims(%{"sub" => sub} = _claims) do
    User.fetch(sub)
  end

  @impl Guardian
  def resource_from_claims(_claims) do
    {:error, :missing_subject}
  end

  @impl Guardian
  def build_claims(claims = %{"iss" => iss}, user, _opts) do
    extra_claims = %{
      "#{iss}/admin" => user.is_admin || false,
      "#{iss}/email" => user.email,
      "#{iss}/first_name" => user.first_name,
      "#{iss}/last_name" => user.last_name,
    }

    {:ok, Map.merge(claims, extra_claims)}
  end
end
