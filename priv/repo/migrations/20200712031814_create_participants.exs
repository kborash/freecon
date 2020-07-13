defmodule Freecon.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :name, :string
      add :identifier, :uuid
      add :room_id, references(:rooms, on_delete: :nothing)

      timestamps()
    end

    create index(:participants, [:room_id])
  end
end
