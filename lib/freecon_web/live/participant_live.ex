defmodule FreeconWeb.ParticipantLive do
  use FreeconWeb, :live_view

  alias Freecon.Participants

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(1000, self(), :tick)
    end

    socket =
      assign(
        socket,
        bid: nil,
        ask: nil,
        quantity: nil,
        mode: "bid",
        participant: nil,
        resources: nil
      )

    {:ok, socket}
  end

  def handle_params(
        %{"code" => room_code, "participant" => participant_uuid} = _params,
        _uri,
        socket
      ) do

    participant = Participants.get_participant_by_identifier(participant_uuid)
    Phoenix.PubSub.subscribe(Freecon.PubSub, room_code)
    socket = assign(socket, participant: participant)
    socket = assign_game(socket, room_code)
    socket = assign(socket, time_remaining: time_remaining(socket.assigns.game.round_ends))
    {:noreply, socket}
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

  def handle_info(:tick, socket) do
    expiration_time = socket.assigns.game.round_ends
    socket = assign(socket, time_remaining: time_remaining(expiration_time))
    {:noreply, socket}
  end

  defp check_bid(socket, bid, quantity) when bid == "", do: socket

  defp check_bid(%{assigns: %{name: name, participant: participant}} = socket, bid, quantity) do
    if funds_available?(socket, bid, quantity) do
      :ok = GenServer.cast(via_tuple(name), {:bid, bid, quantity, participant})
      :ok = Phoenix.PubSub.broadcast(Freecon.PubSub, name, :update)
      assign_game(socket)
    else
      socket
      |> put_flash(:error, "You don't have enough enough cash.")
    end
  end

  defp check_ask(socket, ask, quantity) when ask == "", do: socket

  defp check_ask(%{assigns: %{name: name, participant: participant}} = socket, ask, quantity) do
    if shares_available?(socket, quantity) do
      :ok = GenServer.cast(via_tuple(name), {:ask, ask, quantity, participant})
      :ok = Phoenix.PubSub.broadcast(Freecon.PubSub, name, :update)
      assign_game(socket)
    else
      socket
      |> put_flash(:error, "You don't have enough shares.")
    end
  end

  defp funds_available?(socket, price, quantity) do
    price * quantity < socket.assigns.resources.cash
  end

  defp shares_available?(socket, quantity) do
    quantity > socket.assigns.resources.shares
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

    resources =
      Enum.find(game.participants, fn p -> p.identifier == socket.assigns.participant.identifier end)

    assign(socket,
      game: game,
      quanitiy: nil,
      bid: nil,
      ask: nil,
      resources: resources
    )
  end

  defp time_remaining(expiration_time) do
    Timex.Interval.new(from: Timex.now(), until: expiration_time)
    |> Timex.Interval.duration(:seconds)
    |> Timex.Duration.from_seconds()
    |> Timex.format_duration(:humanized)
  end
end