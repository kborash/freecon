defmodule Freecon.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string
      add :code, :string
      add :active, :boolean, default: false, null: false
      add :professor_id, references(:professors, on_delete: :nothing)

      timestamps()
    end

    create index(:rooms, [:professor_id])
  end
end
