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
    socket = assign(
      socket,
      game: GenServer.call(via_tuple(socket.assigns.room.code), :game)
    )
    {:noreply, socket}
  end

  defp via_tuple(name) do
    {:via, Registry, {Freecon.GameRegistry, name}}
  end
end