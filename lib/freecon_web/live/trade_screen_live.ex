defmodule FreeconWeb.TradeScreenLive do
  use FreeconWeb, :live_view

  alias Freecon.Game

  def mount(_params, _session, socket) do#
    socket = assign(
      socket,
      bid: nil,
      ask: nil,
      quantity: 1,
      mode: "bid"
    )
    {:ok, socket}
  end

  def handle_params(%{"name" => name} = _params, _uri, socket) do
    Phoenix.PubSub.subscribe(Freecon.PubSub, name)
    {:noreply, assign_game(socket, name)}
  end

  def handle_params(_params, _uri, socket) do
    name =
      ?A..?Z
      |> Enum.take_random(6)
      |> List.to_string()

    {:ok, _pid} = DynamicSupervisor.start_child(Freecon.GameSupervisor, {Game, name: via_tuple(name)})

    {:noreply,
      push_redirect(
        socket,
        to: FreeconWeb.Router.Helpers.live_path(socket, FreeconWeb.TradeScreenLive, name: name)
      )
    }
  end

  def render(assigns) do
    ~L"""
      <form phx-submit="bid">
      <table>
        <tbody>
          <tr>
            <td>Bid</td>
            <td><input type="number" min="1" name="bid" value="<%= @bid %>"></td>
          </tr>
          <tr>
            <td>Quantity</td>
            <td><input type="number" min="1" name="quantity" value="<%= @quantity %>"></td>
          </tr>
        </tbody>
      </table>
      <input type="submit" value="Submit">
      </form>

      <form phx-submit="ask">
      <table>
        <tbody>
          <tr>
            <td>Ask</td>
            <td><input type="number" min="1" name="ask" value="<%= @ask %>"></td>
          </tr>
          <tr>
            <td>Quantity</td>
            <td><input type="number" min="1" name="quantity" value="<%= @quantity %>"></td>
          </tr>
        </tbody>
      </table>
      <input type="submit" value="Submit">
      </form>

      <h2 class=text-3xl text-center">Market Prices</h2>
      <div>Market Bid: <%= @game.market_bid %></div>
      <div>Market Ask: <%= @game.market_ask %></div>

      <hr />
      <div id="asks">
        <h2 class="font-bold text-2xl">Asks</h2>
        <%= for order <- @game.asks do %>
          <p><%= order[:quantity] %> at <%= order[:price] %></p>
        <% end %>
      </div>
      <div id="bids">
        <h2 class="font-bold text-2xl">Bids</h2>
        <%= for order <- @game.bids do %>
          <p><%= order[:quantity] %> at <%= order[:price] %></p>
        <% end %>
      </div>
      <hr />
      <div id="transactions">
        <h2 class="font-bold text-2xl">Cleared Transactions</h2>
        <%= for transaction <- @game.transactions do %>
        <p><%= transaction[:quantity] %> at <%= transaction[:price] %></p>
        <% end %>
      </div>

    """
  end

  def handle_event("bid", %{"bid" => bid, "quantity" => quantity}, socket) do
    socket = check_bid(socket, bid, quantity)
    {:noreply, socket}
  end

  def handle_event("ask", %{"ask" => ask, "quantity" => quantity}, socket) do
    socket = check_ask(socket, ask, quantity)
    {:noreply, socket}
  end

  def handle_info(:update, socket) do
    {:noreply, assign_game(socket)}
  end

  defp check_bid(socket, bid, quantity) when bid == "", do: socket
  defp check_bid(%{assigns: %{name: name}} = socket, bid, quantity) do
    :ok = GenServer.cast(via_tuple(name), {:bid, bid, quantity})
    :ok = Phoenix.PubSub.broadcast(Freecon.PubSub, name, :update)
    assign_game(socket)
  end

  defp check_ask(socket, ask, quantity) when ask == "", do: socket
  defp check_ask(%{assigns: %{name: name}} = socket, ask, quantity) do
    :ok = GenServer.cast(via_tuple(name), {:ask, ask, quantity})
    :ok = Phoenix.PubSub.broadcast(Freecon.PubSub, name, :update)
    assign_game(socket)
  end

  defp via_tuple(name) do
    {:via, Registry, {Freecon.GameRegistry, name}}
  end

  defp assign_game(socket, name) do
    socket
    |> assign(name: name)
    |> assign_game
  end

  defp assign_game(%{assigns: %{name: name}} = socket) do
    game = GenServer.call(via_tuple(name), :game)
    assign(socket,
      game: game,
      quanitiy: 1,
      bid: nil,
      ask: nil
    )
  end
end