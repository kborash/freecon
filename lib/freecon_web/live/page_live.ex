defmodule FreeconWeb.PageLive do
  use FreeconWeb, :live_view

  alias Freecon.Experiments

  @impl true
  def mount(_params, _session, socket) do
    # TODO: Check if they're logged in as a participant, redirect if so

    socket = assign(socket,
      name: "",
      room_code: ""
    )

    {:ok, socket}
  end

  # TODO: Handle joining a session
  def handle_event("join", %{"name" => name, "code" => room_code}, socket) do
    with room when not is_nil(room) <- Experiments.find_room_by_code(room_code) do
      socket = put_flash(socket, :info, "Joining #{room_code} as #{name}")
      participant_uuid = Ecto.UUID.generate()

      # TODO: Make sure the room is active, join the room


      # TODO: Redirect to the
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
