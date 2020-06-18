defmodule FreeconWeb.RoomMonitor do
  use FreeconWeb, :live_view

  # TODO: Handle extracting room id
  def mount(_, _, socket) do
    {:ok, socket}
  end
end