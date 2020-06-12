defmodule FreeconWeb.ProfessorDashboard do
  use FreeconWeb, :live_view

  alias Freecon.Experiments

  def mount(_params, session, socket) do
    professor = session["professor"]
    socket = assign(
      socket,
      professor: professor,
      active_rooms: Experiments.active_rooms(professor[:id]),
      closed_rooms: Experiments.closed_rooms(professor[:id])
    )
    {:ok, socket, temporary_assigns: [active_rooms: [], closed_rooms: []]}
  end

  def handle_event("add-room", _, socket) do
    {:ok, room} = Experiments.create_room(%{professor_id: socket.assigns.professor[:id], name: "Placeholder Name"})
    socket = assign_rooms(socket)
    {:noreply, socket}
  end

  def handle_event("deactivate-room", %{"room_id" => room_id}, socket) do
    Experiments.close_room(socket.assigns.professor[:id], room_id)
    socket = assign_rooms(socket)
    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <button phx-click="add-room" class="bg-blue-500 text-white font-semibold px-4 py-2 rounded">Create Room</button>

    <h1 class="font-bold text-5xl">Active Rooms</h1>
    <%= for room <- @active_rooms do %>
      <h2><%= room.code %> <button phx-click="deactivate-room" phx-value-room_id="<%= room.id %>">Deactivate</button></h2>
    <% end %>

    <h1 class="font-bold text-5xl">Inactive Rooms</h1>
    <%= for room <- @closed_rooms do %>
      <h2><%= room.code %></h2>
    <% end %>
    """
  end

  def assign_rooms(socket) do
    assign(socket,
      active_rooms: Experiments.active_rooms(socket.assigns.professor[:id]),
      closed_rooms: Experiments.closed_rooms(socket.assigns.professor[:id])
    )
  end
end