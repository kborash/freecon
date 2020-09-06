defmodule Freecon.RoundResults do
  @moduledoc """
  The RoundResults context.
  """

  import Ecto.Query, warn: false
  alias Freecon.Repo

  alias Freecon.RoundResults.RoundResult
  alias Freecon.Rounds.Round
  alias Freecon.Games.Game
  alias Freecon.Participants.Participant

  @doc """
  Returns the list of round_results.

  ## Examples

      iex> list_round_results()
      [%RoundResult{}, ...]

  """
  def list_round_results do
    Repo.all(RoundResult)
  end

  @doc """
  Returns the list of round_results for a particular participant and game.

  ## Examples

      iex> list_round_results(7, "00e0742b-ca96-440d-80cc-5521d762f082")
      [%RoundResult{}, ...]

  """
  def list_round_results(game_id, participant_id) do
    query = from rr in RoundResult,
            join: r in Round,
            on: [id: rr.round_id],
            join: g in Game,
            on: [id: r.game_id],
            where: g.id == ^game_id and rr.participant_id == ^participant_id,
            order_by: [desc: r.round_number],
            select: map(rr, [:cash, :dividends, :interest, :shares]),
            select_merge: %{round_number: r.round_number}

    Repo.all(query)
  end

  @doc """
  Gets a single round_result.

  Raises `Ecto.NoResultsError` if the Round result does not exist.

  ## Examples

      iex> get_round_result!(123)
      %RoundResult{}

      iex> get_round_result!(456)
      ** (Ecto.NoResultsError)

  """
  def get_round_result!(id), do: Repo.get!(RoundResult, id)

  @doc """
  Creates a round_result.

  ## Examples

      iex> create_round_result(%{field: value})
      {:ok, %RoundResult{}}

      iex> create_round_result(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_round_result(attrs \\ %{}) do
    %RoundResult{}
    |> RoundResult.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a round_result.

  ## Examples

      iex> update_round_result(round_result, %{field: new_value})
      {:ok, %RoundResult{}}

      iex> update_round_result(round_result, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_round_result(%RoundResult{} = round_result, attrs) do
    round_result
    |> RoundResult.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a round_result.

  ## Examples

      iex> delete_round_result(round_result)
      {:ok, %RoundResult{}}

      iex> delete_round_result(round_result)
      {:error, %Ecto.Changeset{}}

  """
  def delete_round_result(%RoundResult{} = round_result) do
    Repo.delete(round_result)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking round_result changes.

  ## Examples

      iex> change_round_result(round_result)
      %Ecto.Changeset{data: %RoundResult{}}

  """
  def change_round_result(%RoundResult{} = round_result, attrs \\ %{}) do
    RoundResult.changeset(round_result, attrs)
  end
end
