defmodule Freecon.Repo.Migrations.CreateGameTable do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :name, :string
      add :parameters, :map
      add :active, :boolean
      add :game_type, :string

      add :room_id, references(:rooms)

      timestamps()
    end
  end
end