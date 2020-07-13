defmodule Freecon.Repo.Migrations.CreateRounds do
  use Ecto.Migration

  def change do
    create table(:rounds) do
      add :round_number, :integer
      add :completed, :boolean, default: false, null: false
      add :game_id, references(:games, on_delete: :nothing)

      timestamps()
    end

    create index(:rounds, [:game_id])
  end
end
