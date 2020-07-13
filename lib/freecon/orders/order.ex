defmodule Freecon.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  alias Freecon.Rounds.Round
  alias Freecon.Participants.Participant

  schema "orders" do
    field :price, :integer
    field :quantity, :integer
    field :type, :string
    belongs_to :participant, Participant
    belongs_to :round, Round

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:price, :quantity, :type, :participant_id, :round_id])
    |> validate_required([:price, :quantity, :type, :participant_id, :round_id])
  end
end
