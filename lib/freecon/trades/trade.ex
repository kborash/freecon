defmodule Freecon.Trades.Trade do
  use Ecto.Schema
  import Ecto.Changeset

  alias Freecon.Rounds.Round
  alias Freecon.Participants.Participant

  schema "trades" do
    field :price, :integer
    field :quantity, :integer

    belongs_to :buyer, Participant, foreign_key: :buyer_id
    belongs_to :seller, Participant, foreign_key: :seller_id
    belongs_to :round, Round

    timestamps()
  end

  @doc false
  def changeset(trade, attrs) do
    trade
    |> cast(attrs, [:price, :quantity, :buyer_id, :seller_id, :round_id])
    |> validate_required([:price, :quantity, :buyer_id, :seller_id, :round_id])
  end
end
