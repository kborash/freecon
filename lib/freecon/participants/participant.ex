defmodule Freecon.Participants.Participant do
  use Ecto.Schema
  import Ecto.Changeset

  alias Freecon.Rooms.Room

  schema "participants" do
    field :identifier, Ecto.UUID
    field :name, :string
    belongs_to :room, Room

    timestamps()
  end

  @doc false
  def changeset(participant, attrs) do
    participant
    |> cast(attrs, [:name, :identifier, :room_id])
    |> validate_required([:name, :identifier, :room_id])
  end
end
