defmodule Reflection.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password, :string, null: false
      add :first_name, :string
      add :last_name, :string
      add :is_admin, :boolean
      timestamps()
    end
  end
end
