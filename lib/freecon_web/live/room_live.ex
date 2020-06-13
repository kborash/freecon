defmodule FreeconWeb.RoomLive do
  use FreeconWeb, :live_view

  alias Freecon.Experiments

  def mount(%{"id" => room_id}, session, socket) do
    room = Experiments.get_room_for_professor(room_id, session["professor"][:id])

    if room == [] do
      socket = put_flash(socket, :error, "Room not found.")
      {:ok, push_redirect(socket, to: "/")}
    else
      {:ok, socket}
    end
  end

  def render(assigns) do
    ~L"""
"""
  end
end