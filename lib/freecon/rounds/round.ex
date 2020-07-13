defmodule Freecon.Rounds.Round do
  use Ecto.Schema
  import Ecto.Changeset

  alias Freecon.Games.Game

  schema "rounds" do
    field :completed, :boolean, default: false
    field :round_number, :integer
    belongs_to :game, Game

    timestamps()
  end

  @doc false
  def changeset(round, attrs) do
    round
    |> cast(attrs, [:round_number, :completed])
    |> validate_required([:round_number, :completed])
  end
end
