defmodule FreeconWeb.WaitingLive do
  use FreeconWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"code" => room_code, "participant" => participant_id} = _params, _uri, socket) do
    Phoenix.PubSub.subscribe(Freecon.PubSub, room_code)
    socket = assign(
      socket,
      room_code: room_code,
      participant_uuid: participant_id
    )
    {:noreply, socket}
  end

  def render(assigns) do
    ~L"""
    <div class="homepage-hero h-screen">
      <h1 class="text-shadow-black text-center text-white text-5xl font-bold text-center pt-4 mb-2">Waiting for the game to start...</h1>
    </div>
    """
  end

  def handle_info(:start, socket) do
    {:noreply, push_redirect(
      socket,
      to: FreeconWeb.Router.Helpers.live_path(
        socket,
        FreeconWeb.ParticipantLive,
        code: socket.assigns.room_code,
        participant: socket.assigns.participant_uuid
      )
    )}
  end
end