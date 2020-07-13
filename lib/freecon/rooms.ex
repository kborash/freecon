defmodule Freecon.Rooms do
  @moduledoc """
  The Rooms context.
  """

  import Ecto.Query, warn: false
  alias Freecon.Repo

  alias Freecon.Rooms.Room
  alias Freecon.Games.Game
  alias Freecon.Participants.Participant

  @doc """
  Returns the list of rooms.

  ## Examples

      iex> list_rooms()
      [%Room{}, ...]

  """
  def list_rooms do
    Repo.all(Room)
  end

  @doc """
  Gets a single room.

  Raises `Ecto.NoResultsError` if the Room does not exist.

  ## Examples

      iex> get_room!(123)
      %Room{}

      iex> get_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_room!(id), do: Repo.get!(Room, id)

  @doc """
  Creates a room.

  ## Examples

      iex> create_room(%{field: value})
      {:ok, %Room{}}

      iex> create_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_room(attrs \\ %{}) do
    %Room{code: generate_room_code()}
    |> Room.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a room.

  ## Examples

      iex> update_room(room, %{field: new_value})
      {:ok, %Room{}}

      iex> update_room(room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_room(%Room{} = room, attrs) do
    room
    |> Room.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a room.

  ## Examples

      iex> delete_room(room)
      {:ok, %Room{}}

      iex> delete_room(room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_room(%Room{} = room) do
    Repo.delete(room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking room changes.

  ## Examples

      iex> change_room(room)
      %Ecto.Changeset{data: %Room{}}

  """
  def change_room(%Room{} = room, attrs \\ %{}) do
    Room.changeset(room, attrs)
  end

  def find_by_code(room_code) do
    Repo.get_by(Room, code: room_code)
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

  def games_for_room(room_id) do
    query = from g in Game,
                 where: g.room_id == ^room_id,
                 select: g

    Repo.all(query)
  end

  def participants_in_room(room_id) do
    query = from p in Participant,
                 where: p.room_id == ^room_id,
                 select: p

    Repo.all(query)
  end

  defp generate_room_code() do
    ?A..?Z
    |> Enum.take_random(10)
    |> List.to_string()
  end
end
