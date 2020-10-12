defmodule FreeconWeb.ProfessorDashboard do
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

  def render(assigns) do
    ~L"""
    <div class="w-100 pl-2 pt-2 pb-4">
    <form phx-submit="add-room">
      <div>
        <label>
          <input class="shadow appearance-none border rounded py-2 px-3 text-gray-700 leading-tight focus:outline-none focus:shadow-outline" placeholder="Room name..." type="text" name="room_name" />
        </label>
        <input class="bg-blue-500 text-white font-semibold px-4 py-2 rounded" type="submit" value="Add Room" />
      </div>
    </form>

    <h1 class="font-bold text-5xl">Active Rooms</h1>
    <%= for room <- @active_rooms do %>
    <div>
      <h2 class="text-2xl"><%= room.name %></h2>
      <div class="pl-2">
        <a class="hover:underline cursor-pointer" href="<%= Routes.live_path(@socket, FreeconWeb.RoomLive, room.id) %>">Go to <%= room.code %> dashboard -></a><br />
        <a class="hover:underline cursor-pointer" phx-click="deactivate-room" phx-value-room_id="<%= room.id %>"><button class="bg-gray-500 text-white font-semibold px-2 py-1 rounded">Archive Room</div></a>
      </div>
    <div>
    <% end %>

    <h1 class="font-bold text-5xl">Inactive Rooms</h1>
    <%= for room <- @closed_rooms do %>
    <h2 class="text-2xl"><%= room.name %></h2>
    <div class="pl-2">
      <a class="hover:underline cursor-pointer block" href="<%= Routes.room_review_path(@socket, :show, room.id) %>"><button class="bg-green-500 text-white font-semibold px-2 py-1 rounded">Review room <%= room.code %></button></a>
    </div>
    <% end %>
    </div>
    """
  end

  def handle_event("add-room", %{"room_name" => room_name}, socket) do
    {:ok, room} = Rooms.create_room(%{professor_id: socket.assigns.professor[:id], name: room_name})
    {:ok, game} = Games.create_game(%{
      name: "Assets Trading",
      parameters: %{
        rounds: 10,
        dividends: [1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5],
        interest_rate: 0.10,
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