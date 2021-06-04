defmodule FreeconWeb.RoomMonitor do
  use FreeconWeb, :live_view

  alias Freecon.Rooms

  def mount(%{"id" => room_id}, _, socket) do
    room = Rooms.get_room!(room_id)

    socket = assign(
      socket,
      room: room,
      game: GenServer.call(via_tuple(room.code), :game)
    )

    Phoenix.PubSub.subscribe(Freecon.PubSub, room.code)
    {:ok, socket}
  end

  def handle_info(:update, socket) do
    {:noreply, assign_game(socket)}
  end

  def handle_info(:round_completed, socket) do
    {:noreply, assign_game(socket)}
  end

  def handle_info(:game_completed, socket) do
    {:noreply, push_redirect(
      socket,
      to: Routes.room_review_path(
        socket,
        :show,
        socket.assigns.room.id
      )
    )}
  end

  defp via_tuple(name) do
    {:via, Registry, {Freecon.GameRegistry, name}}
  end

  defp order_book_asks(game) do
    Enum.reverse(Enum.take(Enum.take(game.asks, 5) ++ List.duplicate([price: "--", quantity: "--"], 5), 5))
  end

  defp order_book_bids(game) do
    Enum.take(Enum.take(game.bids, 5) ++ List.duplicate([price: "--", quantity: "--"], 5), 5)
  end

  defp recent_transactions(game) do
    Enum.take(Enum.reverse(Enum.take(game.transactions, 10)) ++ List.duplicate([price: "--", quantity: "--"], 10), 10)
  end

  defp assign_game(socket) do
    assign(
      socket,
      game: GenServer.call(via_tuple(socket.assigns.room.code), :game)
    )
  end
end