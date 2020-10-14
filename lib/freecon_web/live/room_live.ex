defmodule FreeconWeb.RoomLive do
  use FreeconWeb, :live_view

  alias Freecon.Games
  alias Freecon.Rooms
  alias Freecon.GameServer

  def mount(%{"id" => room_id}, session, socket) do
    room = Rooms.get_room_for_professor(room_id, session["professor"][:id])

    active_game = Registry.lookup(Freecon.GameRegistry, room.code) != []

    socket = assign(socket, room: room, active_game: active_game)
    socket = assign_games(socket)

    {:ok, socket, temporary_assigns: [games: []]}
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
          Interest Rate: <%= game.parameters["interest_rate"] * 100 %>%<br />
          Endowment: <%= game.parameters["endowment"] %><br />
          Shares: <%= game.parameters["shares"] %>
        </div>
      </div>
      <% end %>
    </div>

    <div class="pl-1">
      <button phx-click="launch-room" class="rounded bg-red-500 px-4 py-2 text-white font-semibold <%= if @active_game do %> opacity-50 cursor-not-allowed <% end %>">Launch Room</button>
      <button phx-click="monitor-room" class="rounded bg-yellow-500 px-4 py-2 text-white font-semibold <%= if !@active_game do %> opacity-50 cursor-not-allowed <% end %>">Monitor Room</button>
      <button phx-click="review-room" class="rounded bg-green-500 px-4 py-2 text-white font-semibold">Review Room</button>
    </div>
    """
  end

  def handle_event("add-game", _, socket) do
    {:ok, game} =
      Games.create_game(%{
        name: "Assets Trading",
        parameters: %{
          rounds: 10,
          dividends: [1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5],
          interest_rate: 0.05,
          endowment: 100
        },
        room_id: socket.assigns.room.id
      })

    socket = assign_games(socket)

    {:noreply, socket}
  end

  def handle_event("launch-room", _, socket) do
    game = hd(Games.games_for_room(socket.assigns.room.id))

    case game.started do
      true ->
        {:noreply, socket}

      false ->
        Rooms.activate_room(socket.assigns.room.id)
        Games.start_game(game.id)

        {:ok, _pid} =
          DynamicSupervisor.start_child(
            Freecon.GameSupervisor,
            {GameServer, name: via_tuple(socket.assigns.room.code), room: socket.assigns.room}
          )

        Phoenix.PubSub.broadcast(Freecon.PubSub, socket.assigns.room.code, :start)

        {:noreply,
         push_redirect(socket,
           to: Routes.live_path(socket, FreeconWeb.RoomMonitor, socket.assigns.room.id)
         )}
    end
  end

  def handle_event("monitor-room", _, socket) do
    {:noreply,
      push_redirect(socket,
        to: Routes.live_path(socket, FreeconWeb.RoomMonitor, socket.assigns.room.id)
      )}
  end

  def handle_event("review-room", _, socket) do
    game = hd(Games.games_for_room(socket.assigns.room.id))

    case game.started do
      true ->
        {:noreply,
          push_redirect(socket,
            to: Routes.room_review_path(socket, :show, socket.assigns.room.id)
          )}

      _ ->
        {:noreply, socket}
    end
  end

  defp assign_games(socket) do
    socket =
      assign(socket,
        games: Games.games_for_room(socket.assigns.room.id)
      )
  end

  defp via_tuple(name) do
    {:via, Registry, {Freecon.GameRegistry, name}}
  end
end
