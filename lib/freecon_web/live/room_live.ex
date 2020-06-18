defmodule FreeconWeb.RoomLive do
  use FreeconWeb, :live_view

  alias Freecon.Experiments

  def mount(%{"id" => room_id}, session, socket) do
    room = Experiments.get_room_for_professor(room_id, session["professor"][:id])

    if room == [] do
      socket = put_flash(socket, :error, "Room not found.")
      {:ok, push_redirect(socket, to: Routes.live_path(socket, FreeconWeb.ProfessorDashboard))}
    else
      # TODO: Load room's games
      room = hd(room)

      socket = assign(socket, room: room)
      socket = assign_games(socket)

      {:ok, socket, temporary_assigns: [games: []]}
    end
  end

  def render(assigns) do
    ~L"""
    <div>
      <button phx-click="add-game" class="bg-blue-500 text-white font-semibold px-4 py-2 rounded">Add Game</button>
    </div>

    <div id="loaded_games">
      <%= for game <- @games do %>
      <div class="game">
        <h2><%= game.name %></h2>
        <div>
          Rounds: <%= game.parameters["rounds"] %><br />
          Dividends:
          <%= for dividend <- game.parameters["dividends"] do %>
            <span class="px-2 py-1 border border-black rounded font-bold"><%= dividend %></span>
          <% end %><br />
          Endowment: <%= game.parameters["endowment"] %>
        </div>
      </div>
      <% end %>
    </div>

    <div>
      <button phx-click="launch-room" class="rounded bg-red-500 px-4 py-2 text-white font-semibold">Launch Room</div>
    </div>
    """
  end

  def handle_event("add-game", _, socket) do
    {:ok, game} = Experiments.create_game(%{
      name: "Assets Trading",
      parameters: %{
        rounds: 10,
        dividends: [1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5],
        endowment: 100
      },
      room_id: socket.assigns.room.id
    })

    socket = assign_games(socket)

    {:noreply, socket}
  end

  def handle_event("launch-room", _, socket) do
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, FreeconWeb.RoomMonitor, socket.assigns.room.id))}
  end

  defp assign_games(socket) do
    socket = assign(socket,
      games: Experiments.games_for_room(socket.assigns.room.id),
    )
  end
end