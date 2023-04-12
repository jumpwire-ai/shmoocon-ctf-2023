defmodule Reflection.User do
  use Reflection.Schema
  import Ecto.Changeset
  alias Reflection.Repo
  require Logger
  alias __MODULE__

  @derive {Jason.Encoder, only: [:email, :first_name, :last_name, :is_admin]}
  schema "users" do
    field :email, :string
    field :password, :string
    field :first_name, :string
    field :last_name, :string
    field :is_admin, :boolean
    timestamps()
  end

  @doc false
  def changeset(user \\ %__MODULE__{}, attrs) do
    user
    |> cast(attrs, [:email, :password, :first_name, :last_name])
    |> validate_required([:email, :password])
    |> update_change(:password, &hash_password/1)
    |> unique_constraint(:email)
  end

  def fetch(id) do
    case Repo.get(User, id) do
      nil -> {:error, :not_found}
      user -> {:ok, user}
    end
  end

  def create(attrs) do
    attrs
    |> changeset()
    |> Repo.insert()
  end

  def create!(attrs) do
    attrs
    |> changeset()
    |> Repo.insert!()
  end

  def hash_password(password) do
    salt = :crypto.strong_rand_bytes(6) |> Base.encode64(padding: false)
    hash_password(password, salt)
  end

  def hash_password(nil, _), do: nil
  def hash_password(password, salt) do
    case System.cmd("openssl", ["passwd", "-1", "-quiet", "-salt", salt, password]) do
      {out, 0} -> String.trim_trailing(out)

      {err, _} ->
        Logger.error("Failed to generate password hash: #{inspect err}")
        :error
    end
  end

  def validate_password(%{password: hash}, password) do
    [_, salt, _hash] =  String.split(hash, "$", trim: true)
    case hash_password(password, salt) do
      ^hash -> :ok
      _ -> :error
    end
  end
  def validate_password(_, _), do: :error


  def get_by_email(email) do
    case Repo.get_by(User, email: email) do
      nil -> :error
      user -> {:ok, user}
    end
  end

  def login(email, password) do
    with {:ok, user} <- get_by_email(email),
         :ok <- validate_password(user, password) do
      {:ok, user}
    else
      _ -> {:error, :not_found}
    end
  end
end
