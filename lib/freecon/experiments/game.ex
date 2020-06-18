defmodule Freecon.Experiments.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias Freecon.Experiments.Room
  alias Freecon.Experiments.Game

  schema "games" do
    field :name, :string
    field :parameters, :map
    field :active, :boolean, default: false
    field :game_type, :string, default: "AssetBubble"

    belongs_to :room, Room

    timestamps()

  end

  def changeset(%Game{}=game, attrs) do
    game
    |> cast(attrs, [:name, :parameters, :active, :room_id])
    |> validate_required([:name, :parameters, :room_id])
  end
end