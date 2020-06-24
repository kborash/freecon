defmodule Freecon.Accounts.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Freecon.Accounts.Participant
  alias Freecon.Experiments.Room

  schema "participants" do
    field :name, :string
    field :identifier, Ecto.UUID

    belongs_to :room, Room

    timestamps()
  end

  def changeset(%Participant{}=participant, attrs) do
    participant
    |> cast(attrs, [:name, :room_id, :identifier])
    |> validate_required([:name, :room_id, :identifier])
  end
end