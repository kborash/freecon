defmodule Freecon.RoundResults.RoundResult do
  use Ecto.Schema
  import Ecto.Changeset

  schema "round_results" do
    field :cash, :integer
    field :dividends, :integer
    field :interest, :integer
    field :shares, :integer
    field :round_id, :id
    field :participant_id, :id

    timestamps()
  end

  @doc false
  def changeset(round_result, attrs) do
    round_result
    |> cast(attrs, [:shares, :dividends, :cash, :interest, :round_id, :participant_id])
    |> validate_required([:shares, :dividends, :cash, :interest, :round_id, :participant_id])
  end
end
