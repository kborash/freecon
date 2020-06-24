defmodule Freecon.Game do
  use GenServer, restart: :transient

  defstruct market_bid: nil, market_ask: nil, bids: [], asks: [], transactions: [], participants: %{}
  alias Freecon.Game

  @timeout 600_000

  def start_link(options) do
    # TODO: Load game parameters based on room code

    GenServer.start_link(__MODULE__, %Game{}, options)
  end

  @impl true
  def init(game) do
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

#  @impl true
#  def handle_info(:timeout, game) do
#    {:stop, :normal, game}
#  end

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
    bids = [[price: bid, quantity: quantity, posted: Time.utc_now()] | game.bids] |> Enum.sort(&(&1[:price] > &2[:price]))

    game
      |> struct(bids: bids)
      |> process_transactions
      |> set_market_rates
  end

  def process_transactions(game)do
    if length(game.asks) > 0 and length(game.bids) > 0 do
      [low_ask | other_asks] = game.asks
      [high_bid | other_bids] = game.bids
      if high_bid[:price] >= low_ask[:price] do
        cond do
          high_bid[:quantity] > low_ask[:quantity] ->
            # Some of the high bid will need to be returned to the order book
            remainder_quantity = high_bid[:quantity] - low_ask[:quantity]
            process_transactions(struct(game, %{ transactions: game.transactions ++ [low_ask], asks: other_asks, bids: [[price: high_bid[:price], quantity: remainder_quantity] | other_bids]}))

          low_ask[:quantity] > high_bid[:quantity] ->
            # Some of the low ask will need to be returned to the order book
            remainder_quantity = low_ask[:quantity] - high_bid[:quantity]
            clearing_price = case Time.compare(low_ask[:posted], high_bid[:posted]) do
              _ ->
                100
            end
            process_transactions(struct(game, %{ transactions: game.transactions ++ [high_bid], asks: [[price: low_ask[:price], quantity: remainder_quantity] | other_asks], bids: other_bids}))

          true ->
            struct(game, %{ transactions: game.transactions ++ [high_bid], asks: other_asks, bids: other_bids})
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
end