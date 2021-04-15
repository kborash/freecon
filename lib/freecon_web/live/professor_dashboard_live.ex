defmodule FreeconWeb.ProfessorDashboardLive do
  use FreeconWeb, :live_view

  alias Freecon.Rooms
  alias Freecon.Games
  alias Freecon.Accounts

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])

    socket = assign_current_user(socket, session)

    socket = assign(
      socket,
      user: user,
      active_rooms: Rooms.active_rooms(user.id),
      closed_rooms:  Rooms.closed_rooms(user.id)
    )
    {:ok, socket, temporary_assigns: [active_rooms: [], closed_rooms: []]}
  end

  def handle_event("add-room", %{"room_name" => room_name}, socket) do
    {:ok, room} = Rooms.create_room(%{user_id: socket.assigns.user.id, name: room_name})
    {:ok, game} = Games.create_game(%{
      name: "Assets Trading",
      parameters: %{
        rounds: 10,
        dividends: [1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5],
        interest_rate: 0.05,
        endowment: 100,
        shares: 5
      },
      room_id: room.id
    })
    socket = assign_rooms(socket)
    {:noreply, socket}
  end

  def handle_event("deactivate-room", %{"room_id" => room_id}, socket) do
    Rooms.close_room(socket.assigns.user.id, room_id)
    socket = assign_rooms(socket)
    {:noreply, socket}
  end

  def assign_rooms(socket) do
    assign(socket,
      active_rooms: Rooms.active_rooms(socket.assigns.user.id),
      closed_rooms: Rooms.closed_rooms(socket.assigns.user.id)
    )
  end
end