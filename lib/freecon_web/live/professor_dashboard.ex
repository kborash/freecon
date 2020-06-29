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

  def render(assigns) do
    ~L"""
    <form phx-submit="add-room">
      <div class="ml-2 mt-2">
        <label>
          <input class="shadow appearance-none border rounded py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" placeholder="Room name..." type="text" name="room_name" />
        </label>
        <input class="bg-blue-500 text-white font-semibold px-4 py-2 rounded" type="submit" value="Add Room" />
      </div>
    </form>

    <h1 class="font-bold text-5xl">Active Rooms</h1>
    <%= for room <- @active_rooms do %>
      <h2>Name: <%= room.name %>, Code: <a class="hover:underline cursor-pointer" href="<%= Routes.live_path(@socket, FreeconWeb.RoomLive, room.id) %>"><%= room.code %></a> | <a class="hover:underline cursor-pointer" phx-click="deactivate-room" phx-value-room_id="<%= room.id %>">Deactivate</a></h2>
    <% end %>

    <h1 class="font-bold text-5xl">Inactive Rooms</h1>
    <%= for room <- @closed_rooms do %>
      <h2><%= room.code %></h2>
    <% end %>
    """
  end

  def handle_event("add-room", %{"room_name" => room_name}, socket) do
    {:ok, room} = Experiments.create_room(%{professor_id: socket.assigns.professor[:id], name: room_name})
    {:ok, game} = Experiments.create_game(%{
      name: "Assets Trading",
      parameters: %{
        rounds: 10,
        dividends: [1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5],
        endowment: 100
      },
      room_id: room.id
    })
    socket = assign_rooms(socket)
    {:noreply, socket}
  end

  def handle_event("deactivate-room", %{"room_id" => room_id}, socket) do
    Experiments.close_room(socket.assigns.professor[:id], room_id)
    socket = assign_rooms(socket)
    {:noreply, socket}
  end

  def assign_rooms(socket) do
    assign(socket,
      active_rooms: Experiments.active_rooms(socket.assigns.professor[:id]),
      closed_rooms: Experiments.closed_rooms(socket.assigns.professor[:id])
    )
  end
end