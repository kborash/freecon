defmodule FreeconWeb.ParticipantLive do
  use FreeconWeb, :live_view

  alias Freecon.Game

  def mount(_params, _session, socket) do
    socket =
      assign(
        socket,
        bid: nil,
        ask: nil,
        quantity: nil,
        mode: "bid"
      )

    {:ok, socket}
  end

  def handle_params(%{"code" => room_code, "participant" => participant_uuid} = _params, _uri, socket) do
    Phoenix.PubSub.subscribe(Freecon.PubSub, room_code)
    {:noreply, assign_game(socket, room_code)}
  end

  def handle_params(_params, _uri, socket) do
    name =
      ?A..?Z
      |> Enum.take_random(6)
      |> List.to_string()

    {:ok, _pid} =
      DynamicSupervisor.start_child(Freecon.GameSupervisor, {Game, name: via_tuple(name)})

    {:noreply,
     push_redirect(
       socket,
       to:
         FreeconWeb.Router.Helpers.live_path(
           socket,
           FreeconWeb.ParticipantLive,
           code: "room_code",
           participant: "participant_uuid"
         )
     )}
  end

  def handle_event("bid-mode", _, socket) do
    socket = assign(socket, :mode, "bid")
    {:noreply, socket}
  end

  def handle_event("ask-mode", _, socket) do
    socket = assign(socket, :mode, "ask")
    {:noreply, socket}
  end

  def handle_event("bid", %{"bid" => bid, "quantity" => quantity}, socket) do
    socket = check_bid(socket, bid, quantity)
    {:noreply, socket}
  end

  def handle_event("ask", %{"ask" => ask, "quantity" => quantity}, socket) do
    socket = check_ask(socket, ask, quantity)
    {:noreply, socket}
  end

  def handle_info(:update, socket) do
    {:noreply, assign_game(socket)}
  end

  defp check_bid(socket, bid, quantity) when bid == "", do: socket

  defp check_bid(%{assigns: %{name: name}} = socket, bid, quantity) do
    :ok = GenServer.cast(via_tuple(name), {:bid, bid, quantity})
    :ok = Phoenix.PubSub.broadcast(Freecon.PubSub, name, :update)
    assign_game(socket)
  end

  defp check_ask(socket, ask, quantity) when ask == "", do: socket

  defp check_ask(%{assigns: %{name: name}} = socket, ask, quantity) do
    :ok = GenServer.cast(via_tuple(name), {:ask, ask, quantity})
    :ok = Phoenix.PubSub.broadcast(Freecon.PubSub, name, :update)
    assign_game(socket)
  end

  defp via_tuple(name) do
    {:via, Registry, {Freecon.GameRegistry, name}}
  end

  defp assign_game(socket, name) do
    socket
    |> assign(name: name)
    |> assign_game
  end

  defp assign_game(%{assigns: %{name: name}} = socket) do
    game = GenServer.call(via_tuple(name), :game)

    assign(socket,
      game: game,
      quanitiy: nil,
      bid: nil,
      ask: nil
    )
  end
end
