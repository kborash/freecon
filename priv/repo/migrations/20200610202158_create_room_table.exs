defmodule Freecon.Repo.Migrations.CreateRoomTable do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :name, :string
      add :professor_id, references(:professors)
      add :code, :string
      add :active, :boolean

      timestamps()
    end
  end
end
