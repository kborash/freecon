defmodule Freecon.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias Freecon.Rooms.Room

  schema "games" do
    field :game_type, :string, default: "AssetBubble"
    field :name, :string
    field :parameters, :map
    field :started, :boolean, default: false
    belongs_to :room, Room

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:name, :parameters, :started, :game_type, :room_id])
    |> validate_required([:name, :parameters, :started, :game_type, :room_id])
  end
end
