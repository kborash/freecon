defmodule Freecon.Experiments do
  import Ecto.Query, warn: false

  alias Freecon.Repo

  alias Freecon.Accounts.Professor
  alias Freecon.Experiments.Room
  alias Freecon.Experiments.Game
  alias Freecon.Accounts.Participant

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
                 order_by: [desc: :updated_at],
                 select: r

    Repo.all(query)
  end

  def closed_rooms(professor_id) do
    query = from r in Room,
                 where: r.professor_id == ^professor_id and r.active == false,
                 order_by: [desc: :updated_at],
                 select: r

    Repo.all(query)
  end

  def get_room_for_professor(room_id, professor_id) do
    query = from r in Room,
                 where: r.professor_id == ^professor_id and r.id == ^room_id,
                 select: r

    Repo.all(query)
  end

  def find_room_by_code(room_code) do
    Repo.get_by(Room, code: room_code)
  end

  def get_active_game(room_id) do
    query = from g in Game,
                 where: g.room_id == ^room_id and g.active == true,
                 select: g

    case Repo.all(query) do
      [] ->
        {:error, "No active game"}
      game ->
        {:ok, hd(game)}
    end
  end

  def new_game() do
    Game.changeset(%Game{}, %{})
  end

  def create_game(attrs) do
    # TODO: Add round creation logic
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  def join_room(attrs) do
    %Participant{}
    |> Participant.changeset(attrs)
    |> Repo.insert()
  end

  def games_for_room(room_id) do
    query = from g in Game,
            where: g.room_id == ^room_id,
            select: g

    Repo.all(query)
  end

  defp generate_room_code() do
    ?A..?Z
    |> Enum.take_random(10)
    |> List.to_string()
  end
end