defmodule Freecon.Games.GameParameters do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:rounds, :interest_rate, :endowment, :initial_shares, :dividend_schedule]}
  schema "game_parameters" do
    field :rounds, :integer, default: 20
    field :interest_rate, :float, default: 0.01
    field :endowment, :integer, default: 100
    field :initial_shares, :integer, default: 5
    field :dividend_schedule, {:array, :float}, default: [0.1, 0.05, 0.1, 0.05, 0.1, 0.05, 0.1, 0.05, 0.1, 0.05, 0.1, 0.05, 0.1, 0.05, 0.1, 0.05, 0.1, 0.05, 0.1, 0.05]
  end

  @doc false
  def changeset(game_parameters, attrs) do
    game_parameters
    |> cast(attrs, [:rounds, :interest_rate, :endowment, :initial_shares, :dividend_schedule])
    |> validate_required([:rounds, :interest_rate, :endowment, :initial_shares, :dividend_schedule])
  end
end
