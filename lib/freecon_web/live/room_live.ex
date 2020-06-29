defmodule FreeconWeb.RoomLive do
  use FreeconWeb, :live_view

  alias Freecon.Experiments
  alias Freecon.Game

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
      <h1 class="text-center text-5xl">Room Code: <%= @room.code %></h1>
    </div>
    <hr />
    <div id="loaded_games">
      <%= for game <- @games do %>
      <div class="game pl-1">
        <h2 class="font-bold text-xl"><%= game.name %></h2>
        <div>
          Rounds: <%= game.parameters["rounds"] %><br />
          Dividends:
          <%= for dividend <- game.parameters["dividends"] do %>
            <span class="px-2 py-1 border border-black rounded font-bold"><%= dividend %></span>
          <% end %><br />
          Endowment: <%= game.parameters["endowment"] %><br />
          Shares: <%= game.parameters["shares"] %>
        </div>
      </div>
      <% end %>
    </div>

    <div class="pl-1">
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
    game = hd(Experiments.games_for_room(socket.assigns.room.id))

    Experiments.start_game(game.id)

    {:ok, _pid} =
      DynamicSupervisor.start_child(Freecon.GameSupervisor, {Game, name: via_tuple(socket.assigns.room.code), room: socket.assigns.room})

    Phoenix.PubSub.broadcast(Freecon.PubSub, socket.assigns.room.code, :start)
    {:noreply, push_redirect(socket, to: Routes.live_path(socket, FreeconWeb.RoomMonitor, socket.assigns.room.id))}
  end

  defp assign_games(socket) do
    socket = assign(socket,
      games: Experiments.games_for_room(socket.assigns.room.id),
    )
  end

  defp via_tuple(name) do
    {:via, Registry, {Freecon.GameRegistry, name}}
  end
end