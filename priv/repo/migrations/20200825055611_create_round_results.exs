defmodule Freecon.Repo.Migrations.CreateRoundResults do
  use Ecto.Migration

  def change do
    create table(:round_results) do
      add :shares, :integer
      add :dividends, :integer
      add :cash, :integer
      add :interest, :integer
      add :round_id, references(:rounds, on_delete: :nothing)
      add :participant_id, references(:participants, on_delete: :nothing)

      timestamps()
    end

    create index(:round_results, [:round_id])
    create index(:round_results, [:participant_id])
  end
end
