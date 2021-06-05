defmodule Freecon.Games.GameParameters do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:rounds, :interest_rate, :endowment, :initial_shares, :dividend_schedule]}
  schema "game_parameters" do
    field :rounds, :integer, default: 15
    field :interest_rate, :float, default: 0.05
    field :endowment, :integer, default: 800
    field :initial_shares, :integer, default: 10
    field :dividend_schedule, {:array, :integer}, default: [1, 2, 3, 4, 5]
  end

  @doc false
  def changeset(game_parameters, attrs) do
    game_parameters
    |> cast(attrs, [:rounds, :interest_rate, :endowment, :initial_shares, :dividend_schedule])
    |> validate_required([:rounds, :interest_rate, :endowment, :initial_shares, :dividend_schedule])
  end
end
