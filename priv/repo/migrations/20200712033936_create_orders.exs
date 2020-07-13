defmodule Freecon.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :price, :integer
      add :quantity, :integer
      add :type, :string
      add :participant_id, references(:participants, on_delete: :nothing)
      add :round_id, references(:rounds, on_delete: :nothing)

      timestamps()
    end

    create index(:orders, [:participant_id])
    create index(:orders, [:round_id])
  end
end
