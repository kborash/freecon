defmodule Freecon.Trades do
  @moduledoc """
  The Trades context.
  """

  import Ecto.Query, warn: false
  alias Freecon.Repo

  alias Freecon.Trades.Trade
  alias Freecon.Rounds.Round

  @doc """
  Returns the list of trades.

  ## Examples

      iex> list_trades()
      [%Trade{}, ...]

  """
  def list_trades do
    Repo.all(Trade)
  end

  @doc """
  Gets a single trade.

  Raises `Ecto.NoResultsError` if the Trade does not exist.

  ## Examples

      iex> get_trade!(123)
      %Trade{}

      iex> get_trade!(456)
      ** (Ecto.NoResultsError)

  """
  def get_trade!(id), do: Repo.get!(Trade, id)

  @doc """
  Creates a trade.

  ## Examples

      iex> create_trade(%{field: value})
      {:ok, %Trade{}}

      iex> create_trade(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_trade(attrs \\ %{}) do
    %Trade{}
    |> Trade.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a trade.

  ## Examples

      iex> update_trade(trade, %{field: new_value})
      {:ok, %Trade{}}

      iex> update_trade(trade, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_trade(%Trade{} = trade, attrs) do
    trade
    |> Trade.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a trade.

  ## Examples

      iex> delete_trade(trade)
      {:ok, %Trade{}}

      iex> delete_trade(trade)
      {:error, %Ecto.Changeset{}}

  """
  def delete_trade(%Trade{} = trade) do
    Repo.delete(trade)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking trade changes.

  ## Examples

      iex> change_trade(trade)
      %Ecto.Changeset{data: %Trade{}}

  """
  def change_trade(%Trade{} = trade, attrs \\ %{}) do
    Trade.changeset(trade, attrs)
  end

  def trade_statistics(game_id, participant_id) do
    # Get total trades
    buys_query =
      from t in Trade,
        left_join: r in Round,
        on: r.id == t.round_id,
        where: r.game_id == ^game_id and (t.buyer_id == ^participant_id),
        select: count()

    sells_query = from t in Trade,
         left_join: r in Round,
         on: r.id == t.round_id,
         where: r.game_id == ^game_id and (t.seller_id == ^participant_id),
         select: count()

    %{
      buys: Repo.one(buys_query),
      sells: Repo.one(sells_query)
    }
  end

  def all_trades_by_round(game_id) do
    query =
      from t in Trade,
        left_join: r in Round,
        on: r.id == t.round_id,
        where: r.game_id == ^game_id,
        group_by: [r.round_number, t.price],
        select: [r.round_number - 1, t.price, sum(t.quantity)]

    Repo.all(query)
  end
end
