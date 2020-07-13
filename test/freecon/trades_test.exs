defmodule Freecon.TradesTest do
  use Freecon.DataCase

  alias Freecon.Trades

  describe "trades" do
    alias Freecon.Trades.Trade

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def trade_fixture(attrs \\ %{}) do
      {:ok, trade} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Trades.create_trade()

      trade
    end

    test "list_trades/0 returns all trades" do
      trade = trade_fixture()
      assert Trades.list_trades() == [trade]
    end

    test "get_trade!/1 returns the trade with given id" do
      trade = trade_fixture()
      assert Trades.get_trade!(trade.id) == trade
    end

    test "create_trade/1 with valid data creates a trade" do
      assert {:ok, %Trade{} = trade} = Trades.create_trade(@valid_attrs)
    end

    test "create_trade/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Trades.create_trade(@invalid_attrs)
    end

    test "update_trade/2 with valid data updates the trade" do
      trade = trade_fixture()
      assert {:ok, %Trade{} = trade} = Trades.update_trade(trade, @update_attrs)
    end

    test "update_trade/2 with invalid data returns error changeset" do
      trade = trade_fixture()
      assert {:error, %Ecto.Changeset{}} = Trades.update_trade(trade, @invalid_attrs)
      assert trade == Trades.get_trade!(trade.id)
    end

    test "delete_trade/1 deletes the trade" do
      trade = trade_fixture()
      assert {:ok, %Trade{}} = Trades.delete_trade(trade)
      assert_raise Ecto.NoResultsError, fn -> Trades.get_trade!(trade.id) end
    end

    test "change_trade/1 returns a trade changeset" do
      trade = trade_fixture()
      assert %Ecto.Changeset{} = Trades.change_trade(trade)
    end
  end
end
