defmodule Freecon.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Freecon.Professors.Professor

  schema "rooms" do
    field :active, :boolean, default: true
    field :code, :string
    field :name, :string
    belongs_to :professor, Professor

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :code, :active, :professor_id])
    |> validate_required([:name, :code, :active, :professor_id])
  end
end
