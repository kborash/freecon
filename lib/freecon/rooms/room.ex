defmodule Freecon.Rooms.Room do
  use Ecto.Schema
  import Ecto.Changeset

  alias Freecon.Accounts.User

  schema "rooms" do
    field :active, :boolean, default: true
    field :code, :string
    field :name, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(room, attrs) do
    room
    |> cast(attrs, [:name, :code, :active, :user_id])
    |> validate_required([:name, :code, :active, :user_id])
  end
end
