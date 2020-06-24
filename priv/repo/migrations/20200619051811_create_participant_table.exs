defmodule Freecon.Repo.Migrations.CreateParticipantTable do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :name, :string
      add :identifier, :uuid

      add :room_id, references(:rooms)

      timestamps()
    end
  end
end
