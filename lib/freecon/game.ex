defmodule Freecon.Game do
  use GenServer, restart: :transient

  defstruct room_name: nil,
            round: 1,
            parameters: nil,
            market_bid: nil,
            market_ask: nil,
            bids: [],
            asks: [],
            transactions: [],
            participants: nil,
            round_ends: nil

  alias Freecon.Game
  alias Freecon.Experiments

  def start_link(options) do
    game = hd(Experiments.games_for_room(options[:room].id))

    participants = initialize_participants(game)

    GenServer.start_link(
      __MODULE__,
      %Game{
        parameters: game.parameters,
        room_name: options[:room].code,
        participants: participants
      },
      options
    )
  end

  @impl true
  def init(game) do
    Process.send_after(self(), :end_round, 60_000)

    game =
      struct(
        game,
        round_ends: Timex.shift(Timex.now(), seconds: 60)
      )

    {:ok, game}
  end

  @impl true
  def handle_call(:game, _from, game) do
    {:reply, game, game}
  end

  @impl true
  def handle_cast({:ask, ask, quantity}, game) do
    {:noreply, Game.process_ask(game, ask, quantity)}
  end

  @impl true
  def handle_cast({:bid, bid, quantity}, game) do
    {:noreply, Game.process_bid(game, bid, quantity)}
  end

  @impl true
  def handle_info(:end_round, game) do
    if game.round < game.parameters["rounds"] do
      game = advance_round(game)
      :ok = Phoenix.PubSub.broadcast(Freecon.PubSub, game.room_name, :update)

      game =
        struct(
          game,
          round_ends: Timex.shift(Timex.now(), seconds: 60)
        )

      Process.send_after(self(), :end_round, 60_000)
      {:noreply, game}
    else
      IO.inspect("Game completed!")
      {:noreply, game}
    end
  end

  def initialize_participants(game) do
    Experiments.participants_in_room(game.room_id)
    |> Enum.map(fn participant ->
      %{
        identifier: participant.identifier,
        cash: game.parameters["endowment"],
        shares: game.parameters["shares"]
      }
    end)
  end

  def process_ask(game, ask, quantity) when ask == "", do: game

  def process_ask(game, ask, quantity) do
    ask = String.to_integer(ask)
    quantity = String.to_integer(quantity)

    asks =
      [[price: ask, quantity: quantity, posted: Time.utc_now()] | game.asks]
      |> Enum.sort(&(&1[:price] < &2[:price]))

    game
    |> struct(asks: asks)
    |> process_transactions
    |> set_market_rates
  end

  def process_bid(game, bid, quantity) when bid == "", do: game

  def process_bid(game, bid, quantity) do
    bid = String.to_integer(bid)
    quantity = String.to_integer(quantity)

    bids =
      [[price: bid, quantity: quantity, posted: Time.utc_now()] | game.bids]
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
        cond do
          high_bid[:quantity] > low_ask[:quantity] ->
            # Some of the high bid will need to be returned to the order book
            remainder_quantity = high_bid[:quantity] - low_ask[:quantity]

            process_transactions(
              struct(game, %{
                transactions: game.transactions ++ [low_ask],
                asks: other_asks,
                bids: [[price: high_bid[:price], quantity: remainder_quantity] | other_bids]
              })
            )

          low_ask[:quantity] > high_bid[:quantity] ->
            # Some of the low ask will need to be returned to the order book
            remainder_quantity = low_ask[:quantity] - high_bid[:quantity]

            clearing_price =
              case Time.compare(low_ask[:posted], high_bid[:posted]) do
                _ ->
                  100
              end

            process_transactions(
              struct(game, %{
                transactions: game.transactions ++ [high_bid],
                asks: [[price: low_ask[:price], quantity: remainder_quantity] | other_asks],
                bids: other_bids
              })
            )

          true ->
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
  end

  def complete_game(game) do
  end
end
