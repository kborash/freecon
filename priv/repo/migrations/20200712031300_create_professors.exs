defmodule Freecon.Repo.Migrations.CreateProfessors do
  use Ecto.Migration

  def change do
    create table(:professors) do
      add :name, :string
      add :email, :string
      add :encrypted_password, :string
      add :active, :boolean, default: false, null: false

      timestamps()
    end

  end
end
