defmodule Freecon.Experiments.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Freecon.Accounts.Professor
  alias Freecon.Experiments.Room

  schema "rooms" do
    field :name, :string
    field :code, :string
    field :active, :boolean, default: true

    belongs_to :professor, Professor

    timestamps()
  end

  def changeset(%Room{}=room, attrs) do
    room
    |> cast(attrs, [:name, :code, :professor_id])
    |> validate_required([:name, :code, :professor_id])
  end
end