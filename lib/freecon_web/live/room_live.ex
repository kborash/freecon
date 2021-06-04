defmodule FreeconWeb.RoomLive do
  use FreeconWeb, :live_view
#  use Phoenix.HTML

  alias Freecon.Games
  alias Freecon.Rooms
  alias Freecon.GameServer
  alias Freecon.Accounts
  alias Freecon.Games.GameParameters

  def mount(%{"id" => room_id}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    room = Rooms.get_room_for_user(room_id, user.id)

    active_game = Registry.lookup(Freecon.GameRegistry, room.code) != []

    socket = assign(socket, room: room, active_game: active_game, changeset: Games.create_game_parameters())
    socket = assign_games(socket)

    {:ok, socket}
  end

  def handle_event("add-game", _, socket) do
    {:ok, game} =
      Games.create_game(%{
        name: "Assets Trading",
        parameters: %{
          rounds: 10,
          dividend_schedule: [1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5, 1, 0.5],
          initial_shares: 5,
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

  def handle_event("validate", %{"game_parameters" => params}, socket) do
    changeset =
      %GameParameters{}
      |> Games.change_game_parameters(params)

    {:noreply,
      socket
      |> assign_games
      |> assign(changeset: changeset)}
  end

  def handle_event("save", %{"game_parameters" => game_parameters_params}, socket) do
    game_parameters_changeset =
      %GameParameters{}
      |> Games.change_game_parameters(game_parameters_params)

    IO.inspect game_parameters_changeset
    case Games.update_game(hd(socket.assigns.games), %{parameters: Ecto.Changeset.apply_changes(game_parameters_changeset)}) do
      {:ok, _} ->
        {:noreply,
        socket
        |> assign(changeset: game_parameters_changeset)
        |> put_flash(:info, "Updated game parameters.")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
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
