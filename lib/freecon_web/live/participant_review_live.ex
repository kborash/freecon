defmodule FreeconWeb.ParticipantReviewLive do
  use FreeconWeb, :live_view

  alias Freecon.Rooms
  alias Freecon.Games
  alias Freecon.Trades
  alias Freecon.Participants
  alias Freecon.RoundResults

  def mount(_params, _session, socket) do
    socket =
      assign(
        socket,
        participant: nil,
      )

    {:ok, socket, layout: {FreeconWeb.LayoutView, "participant.html"}}
  end

  def handle_params(
        %{"code" => room_code, "participant" => participant_uuid} = _params,
        _uri,
        socket
      ) do

    # Get the room
    room = Rooms.find_by_code(room_code)

    # Get the participant
    participant = Participants.get_participant_by_identifier!(participant_uuid)

    # Get the game ID
    game = hd(Rooms.games_for_room(room.id))

    socket =
      socket
      |> assign(game: game, room: room, participant: participant)
      |> assign_round_results
      |> assign_transaction_statistics

    {:noreply, socket}
  end

  defp assign_round_results(socket) do
    round_results = RoundResults.list_round_results(socket.assigns.game.id, socket.assigns.participant.id)
    assign(
      socket,
      final_round_results: hd(round_results),
      round_results: Enum.reverse(round_results)
    )
  end

  defp assign_transaction_statistics(socket) do
    assign(
      socket,
      transaction_statistics: Trades.trade_statistics(socket.assigns.game.id, socket.assigns.participant.id)
    )
  end
end
