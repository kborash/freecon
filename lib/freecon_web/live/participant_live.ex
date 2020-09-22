defmodule FreeconWeb.ParticipantLive do
  use FreeconWeb, :live_view

  alias Freecon.Participants
  alias Freecon.RoundResults

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
        resources: nil,
        display_history: false,
        round_history: []
      )

    {:ok, socket, layout: {FreeconWeb.LayoutView, "participant.html"}}
  end

  def handle_params(
        %{"code" => room_code, "participant" => participant_uuid} = _params,
        _uri,
        socket
      ) do

    participant = Participants.get_participant_by_identifier!(participant_uuid)
    Phoenix.PubSub.subscribe(Freecon.PubSub, room_code)
    socket = assign(socket, participant: participant)
    socket = assign_game(socket, room_code)
    socket = assign(socket, time_remaining: time_remaining(socket.assigns.game.round_ends))
    socket = assign_round_history(socket)
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
    socket = check_bid(socket, String.to_integer(bid), String.to_integer(quantity))
    {:noreply, socket}
  end

  def handle_event("update-bid", %{"bid" => bid, "quantity" => quantity}, socket) do
    socket =
      assign(
        socket,
        bid: bid,
        quantity: quantity
      )
    {:noreply, socket}
  end

  def handle_event("ask", %{"ask" => ask, "quantity" => quantity}, socket) do
    socket = check_ask(socket, String.to_integer(ask), String.to_integer(quantity))
    {:noreply, socket}
  end

  def handle_event("update-ask", %{"ask" => ask, "quantity" => quantity}, socket) do
    socket =
      assign(
        socket,
        ask: ask,
        quantity: quantity
      )
    {:noreply, socket}
  end

  def handle_event("retract-order", _, socket) do
    :ok = GenServer.cast(via_tuple(socket.assigns.name), {:retract_order, socket.assigns.participant})
    :ok = Phoenix.PubSub.broadcast(Freecon.PubSub, socket.assigns.name, :update)
    {:noreply, assign_game(socket)}
  end

  def handle_info(:update, socket) do
    {:noreply, assign_game(socket)}
  end

  def handle_info(:tick, socket) do
    expiration_time = socket.assigns.game.round_ends
    socket = assign(socket, time_remaining: time_remaining(expiration_time))
    {:noreply, socket}
  end

  def handle_info(:round_completed, socket) do
    {:noreply, assign_round_history(socket)}
  end

  def handle_info(:game_completed, socket) do
    {:noreply, push_redirect(
      socket,
      to: FreeconWeb.Router.Helpers.live_path(
        socket,
        FreeconWeb.ParticipantReviewLive,
        code: socket.assigns.room_code,
        participant: socket.assigns.participant_uuid
      )
    )}
  end

  defp check_bid(socket, bid, quantity) when bid == "", do: socket

  defp check_bid(%{assigns: %{name: name, participant: participant}} = socket, bid, quantity) do
    if funds_available?(socket, bid, quantity) do
      :ok = GenServer.cast(via_tuple(name), {:bid, bid, quantity, participant})
      :ok = Phoenix.PubSub.broadcast(Freecon.PubSub, name, :update)
      socket
      |> clear_order_details
      |> assign_game
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
      socket
      |> clear_order_details
      |> assign_game
    else
      socket
      |> put_flash(:error, "You don't have enough shares.")
    end
  end

  defp funds_available?(socket, price, quantity) do
    price * quantity <= socket.assigns.resources.cash
  end

  defp shares_available?(socket, quantity) do
    quantity <= socket.assigns.resources.shares
  end

  defp via_tuple(name) do
    {:via, Registry, {Freecon.GameRegistry, name}}
  end

  defp clear_order_details(socket) do
    assign(socket, bid: nil, ask: nil, quantity: nil)
  end

  defp assign_game(socket, name) do
    socket
    |> assign(name: name)
    |> assign_game
  end

  defp assign_game(%{assigns: %{name: name}} = socket) do
    game = GenServer.call(via_tuple(name), :game)

    resources = game.participants[socket.assigns.participant.id]

    assign(socket,
      game: game,
      quanitiy: nil,
      bid: nil,
      ask: nil,
      resources: resources
    )
  end

  defp assign_round_history(socket) do
    assign(socket,
      round_history: RoundResults.list_round_results(
      socket.assigns.game.game_id,
      socket.assigns.participant.id
    ))
  end

  defp time_remaining(expiration_time) do
    case Timex.now() < expiration_time do
      true ->
        Timex.Interval.new(from: Timex.now(), until: expiration_time)
        |> Timex.Interval.duration(:seconds)
        |> Timex.Duration.from_seconds()
        |> Timex.format_duration(:humanized)
      _ ->
        "Round Finished."
    end
  end

  defp active_order?(game, participant) do
    Enum.any?(game.asks, fn(x) -> x[:participant].id == participant.id end) or
      Enum.any?(game.bids, fn(x) -> x[:participant].id == participant.id end)
  end
end
