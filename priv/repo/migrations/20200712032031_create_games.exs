defmodule Freecon.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games) do
      add :name, :string
      add :parameters, :map
      add :started, :boolean, default: false, null: false
      add :game_type, :string
      add :room_id, references(:rooms, on_delete: :nothing)

      timestamps()
    end

    create index(:games, [:room_id])
  end
end
