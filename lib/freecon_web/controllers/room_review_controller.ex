defmodule FreeconWeb.RoomReviewController do
  use FreeconWeb, :controller

  alias Freecon.Rooms
  alias Freecon.Trades
  alias Freecon.Games

  def show(conn, %{"id" => id}) do
    game = hd(Rooms.games_for_room(id))

    render(conn, "show.html",
      transactions: Jason.encode!(Trades.all_trades_by_round(game.id)),
      expected_values: Jason.encode!(Games.expected_value(game.id)),
      rounds: game.parameters["rounds"]
    )
  end
end
