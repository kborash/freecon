defmodule Freecon.Experiments do
  import Ecto.Query, warn: false

  alias Freecon.Repo

  alias Freecon.Accounts.Professor
  alias Freecon.Experiments.Room

  def new_room do
    Room.changeset(%Room{}, %{})
  end

  def create_room(attrs) do
    %Room{code: generate_room_code()}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  def close_room(professor_id, room_id) do
    Repo.update_all(
      from(r in Room, where: r.professor_id == ^professor_id and r.id == ^room_id),
      set: [active: false]
    )
  end

  def active_rooms(professor_id) do
    query = from r in Room,
            where: r.professor_id == ^professor_id and r.active,
            select: r

    Repo.all(query)
  end

  def closed_rooms(professor_id) do
    query = from r in Room,
                 where: r.professor_id == ^professor_id and r.active == false,
                 select: r

    Repo.all(query)
  end

  defp generate_room_code() do
    ?A..?Z
    |> Enum.take_random(10)
    |> List.to_string()
  end
end