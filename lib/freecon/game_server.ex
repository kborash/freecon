defmodule Freecon.GameServer do
  use GenServer, restart: :transient

  defstruct room_name: nil,
            round: 0,
            round_id: nil,
            game_id: nil,
            parameters: nil,
            market_bid: nil,
            market_ask: nil,
            bids: [],
            asks: [],
            transactions: [],
            participants: nil,
            round_ends: nil

  alias Freecon.GameServer
  alias Freecon.Rooms
  alias Freecon.Rounds
  alias Freecon.Orders
  alias Freecon.Trades

  def start_link(options) do
    game = hd(Rooms.games_for_room(options[:room].id))

    participants = initialize_participants(game)

    GenServer.start_link(
      __MODULE__,
      %GameServer{
        game_id: game.id,
        parameters: game.parameters,
        room_name: options[:room].code,
        participants: participants
      },
      options
    )
  end

  @impl true
  def init(game) do
    Process.send_after(self(), :end_round, 60000_000)

    game = advance_round(game)

    game =
      struct(
        game,
        round_ends: Timex.shift(Timex.now(), seconds: 60000)
      )

    {:ok, game}
  end

  @impl true
  def handle_call(:game, _from, game) do
    {:reply, game, game}
  end

  @impl true
  def handle_cast({:ask, ask, quantity, participant}, game) do
    {:ok, _} =
      Orders.create_order(%{
        price: ask,
        quantity: quantity,
        type: "ask",
        participant_id: participant.id,
        round_id: game.round_id
      })

    {:noreply, GameServer.process_ask(game, ask, quantity, participant)}
  end

  @impl true
  def handle_cast({:bid, bid, quantity, participant}, game) do
    {:ok, _} =
      Orders.create_order(%{
        price: bid,
        quantity: quantity,
        type: "bid",
        participant_id: participant.id,
        round_id: game.round_id
      })

    {:noreply, GameServer.process_bid(game, bid, quantity, participant)}
  end

  @impl true
  def handle_cast({:retract_order, participant}, game) do
    # TODO: Restore resources for retracting order
    asks = Enum.filter(game.asks, fn x -> x[:participant].id != participant.id end)
    bids = Enum.filter(game.bids, fn x -> x[:participant].id != participant.id end)
    game = struct(game, asks: asks, bids: bids)
    game = set_market_rates(game)
    {:noreply, game}
  end

  @impl true
  def handle_info(:end_round, game) do
    if game.round < game.parameters["rounds"] do
      game = advance_round(game)
      :ok = Phoenix.PubSub.broadcast(Freecon.PubSub, game.room_name, :update)

      game =
        struct(
          game,
          round_ends: Timex.shift(Timex.now(), seconds: 60000)
        )

      Process.send_after(self(), :end_round, 60000_000)
      {:noreply, game}
    else
      IO.inspect("Game completed!")
      {:noreply, game}
    end
  end

  def initialize_participants(game) do
    Rooms.participants_in_room(game.room_id)
    |> Enum.map(fn participant ->
      {participant.id,
       %{
         participant: participant.id,
         cash: game.parameters["endowment"],
         shares: game.parameters["shares"]
       }}
    end)
    |> Map.new()
  end

  def process_ask(game, ask, quantity, participant) when ask == "", do: game

  def process_ask(game, ask, quantity, participant) do
    # TODO: Confirm available shares

    asks =
      [
        [price: ask, quantity: quantity, posted: Time.utc_now(), participant: participant]
        | game.asks
      ]
      |> Enum.sort(&(&1[:price] < &2[:price]))

    game
    |> struct(asks: asks)
    |> process_transactions
    |> set_market_rates
  end

  def process_bid(game, bid, quantity, participant) when bid == "", do: game

  def process_bid(game, bid, quantity, participant) do
    # TODO: Confirm available cash

    bids =
      [
        [price: bid, quantity: quantity, posted: Time.utc_now(), participant: participant]
        | game.bids
      ]
      |> Enum.sort(&(&1[:price] > &2[:price]))

    game
    |> struct(bids: bids)
    |> process_transactions
    |> set_market_rates
  end

  def process_transactions(game) do
    if length(game.asks) > 0 and length(game.bids) > 0 do
      [low_ask | other_asks] = game.asks
      [high_bid | other_bids] = game.bids

      if high_bid[:price] >= low_ask[:price] do
        closing_price = calculate_closing_price(high_bid, low_ask)

        cond do
          high_bid[:quantity] > low_ask[:quantity] ->
            # Some of the high bid will need to be returned to the order book
            remainder_quantity = high_bid[:quantity] - low_ask[:quantity]

            save_trade(
              game.round_id,
              low_ask[:participant],
              high_bid[:participant],
              closing_price,
              low_ask[:quantity]
            )

            process_transactions(
              struct(game, %{
                transactions: game.transactions ++ [low_ask],
                asks: other_asks,
                bids: [
                  [
                    price: high_bid[:price],
                    quantity: remainder_quantity,
                    posted: high_bid[:posted],
                    participant: high_bid[:participant]
                  ]
                  | other_bids
                ]
              })
            )

          low_ask[:quantity] > high_bid[:quantity] ->
            # Some of the low ask will need to be returned to the order book
            remainder_quantity = low_ask[:quantity] - high_bid[:quantity]

            save_trade(
              game.round_id,
              low_ask[:participant],
              high_bid[:participant],
              closing_price,
              high_bid[:quantity]
            )

            process_transactions(
              struct(game, %{
                transactions: game.transactions ++ [high_bid],
                asks: [
                  [
                    price: low_ask[:price],
                    quantity: remainder_quantity,
                    posted: low_ask[:posted],
                    participant: low_ask[:participant]
                  ]
                  | other_asks
                ],
                bids: other_bids
              })
            )

          true ->
            # In this case, you can use either the low_ask or high_bid quantity
            save_trade(
              game.round_id,
              low_ask[:participant],
              high_bid[:participant],
              closing_price,
              low_ask[:quantity]
            )

            struct(game, %{
              transactions: game.transactions ++ [high_bid],
              asks: other_asks,
              bids: other_bids
            })
        end
      else
        game
      end
    else
      game
    end
  end

  #  def clear_transaction()

  def set_market_rates(game) do
    game
    |> set_market_ask
    |> set_market_bid
  end

  def set_market_ask(game) do
    case length(game.asks) do
      0 ->
        struct(game, market_ask: nil)

      _ ->
        struct(game, market_ask: hd(game.asks)[:price])
    end
  end

  def set_market_bid(game) do
    case length(game.bids) do
      0 ->
        struct(game, market_bid: nil)

      _ ->
        struct(game, market_bid: hd(game.bids)[:price])
    end
  end

  def create_round(game) do
    {:ok, round} =
      Rounds.create_round(%{
        game_id: game.game_id,
        round_number: game.round
      })

    game
    |> struct(round_id: round.id)
  end

  def complete_round(game) do
    game
  end

  def advance_round(game) do
    game =
      game
      |> struct(
        round: game.round + 1,
        transactions: [],
        bids: [],
        asks: [],
        market_bid: nil,
        market_ask: nil
      )

    create_round(game)
  end

  def complete_game(game) do
  end

  def save_trade(round_id, buyer, seller, price, quantity) do
    {:ok, _} =
      Trades.create_trade(%{
        round_id: round_id,
        buyer_id: buyer.id,
        seller_id: seller.id,
        price: price,
        quantity: quantity
      })
  end

  defp calculate_closing_price(bid, ask) do
    case Time.compare(bid[:posted], ask[:posted]) do
      :lt ->
        bid[:price]

      _ ->
        ask[:price]
    end
  end
end
