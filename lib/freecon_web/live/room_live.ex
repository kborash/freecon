defmodule FreeconWeb.RoomLive do
  use FreeconWeb, :live_view

  alias Freecon.Games
  alias Freecon.Rooms
  alias Freecon.GameServer
  alias Freecon.Accounts

  def mount(%{"id" => room_id}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    room = Rooms.get_room_for_user(room_id, user.id)

    active_game = Registry.lookup(Freecon.GameRegistry, room.code) != []

    socket = assign(socket, room: room, active_game: active_game)
    socket = assign_games(socket)

    {:ok, socket, temporary_assigns: [games: []]}
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
