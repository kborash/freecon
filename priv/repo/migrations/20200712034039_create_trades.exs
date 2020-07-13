defmodule Freecon.Repo.Migrations.CreateTrades do
  use Ecto.Migration

  def change do
    create table(:trades) do
      add :buyer_id, references(:participants, on_delete: :nothing)
      add :seller_id, references(:participants, on_delete: :nothing)
      add :round_id, references(:rounds, on_delete: :nothing)

      add :price, :integer
      add :quantity, :integer

      timestamps()
    end

    create index(:trades, [:buyer_id])
    create index(:trades, [:seller_id])
    create index(:trades, [:round_id])
  end
end
