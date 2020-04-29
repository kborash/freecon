defmodule Freecon.Repo.Migrations.CreateProfessorTable do
  use Ecto.Migration

  def change do
    create table(:professors) do
      add :name, :string
      add :email, :string
      add :active, :boolean, default: false
      add :encrypted_password, :string

      timestamps()
    end

    create unique_index(:professors, [:email])
  end
end
