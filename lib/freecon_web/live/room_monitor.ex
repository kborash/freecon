defmodule FreeconWeb.RoomMonitor do
  use FreeconWeb, :live_view

  def mount(%{"id" => room_id}, _, socket) do

    Phoenix.PubSub.subscribe(Freecon.PubSub, "room_code")
    {:ok, socket}
  end
end