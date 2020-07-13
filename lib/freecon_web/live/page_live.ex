defmodule FreeconWeb.PageLive do
  use FreeconWeb, :live_view

  alias Freecon.Rooms
  alias Freecon.Participants

  @impl true
  def mount(_params, _session, socket) do
    # TODO: Check if they're logged in as a participant, redirect if so

    socket = assign(socket,
      name: "",
      room_code: ""
    )

    {:ok, socket}
  end

  def handle_event("join", %{"name" => name, "code" => room_code}, socket) do
    with room when not is_nil(room) <- Rooms.find_by_code(room_code) do
      socket = put_flash(socket, :info, "Joining #{room_code} as #{name}")
      participant_uuid = Ecto.UUID.generate()

      Participants.create_participant(%{name: name, room_id: room.id, identifier: participant_uuid})

      socket = push_redirect(
        socket,
        to: FreeconWeb.Router.Helpers.live_path(socket, FreeconWeb.WaitingLive, code: room_code, participant: participant_uuid)
      )

      {:noreply, socket}
    else
      _ ->
        socket = put_flash(socket, :error, "Couldn't join #{room_code}. Please make sure that's the correct room code.")
        socket = assign(socket, name: name)
        {:noreply, socket}
    end
  end

end
