defmodule FreeconWeb.ProfessorDashboardLive do
  use FreeconWeb, :live_view

  alias Freecon.Rooms
  alias Freecon.Games

  def mount(_params, session, socket) do
    professor = session["professor"]
    socket = assign(
      socket,
      professor: professor,
      active_rooms: Rooms.active_rooms(professor[:id]),
      closed_rooms: Rooms.closed_rooms(professor[:id])
    )
    {:ok, socket, temporary_assigns: [active_rooms: [], closed_rooms: []]}
  end

  def handle_event("add-room", %{"room_name" => room_name}, socket) do
    {:ok, room} = Rooms.create_room(%{professor_id: socket.assigns.professor[:id], name: room_name})
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
    Rooms.close_room(socket.assigns.professor[:id], room_id)
    socket = assign_rooms(socket)
    {:noreply, socket}
  end

  def assign_rooms(socket) do
    assign(socket,
      active_rooms: Rooms.active_rooms(socket.assigns.professor[:id]),
      closed_rooms: Rooms.closed_rooms(socket.assigns.professor[:id])
    )
  end
end