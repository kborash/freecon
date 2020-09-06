defmodule Freecon.RoundResultsTest do
  use Freecon.DataCase

  alias Freecon.RoundResults

  describe "round_results" do
    alias Freecon.RoundResults.RoundResult

    @valid_attrs %{cash: 42, dividents: 42, interest: 42, shares: 42}
    @update_attrs %{cash: 43, dividents: 43, interest: 43, shares: 43}
    @invalid_attrs %{cash: nil, dividents: nil, interest: nil, shares: nil}

    def round_result_fixture(attrs \\ %{}) do
      {:ok, round_result} =
        attrs
        |> Enum.into(@valid_attrs)
        |> RoundResults.create_round_result()

      round_result
    end

    test "list_round_results/0 returns all round_results" do
      round_result = round_result_fixture()
      assert RoundResults.list_round_results() == [round_result]
    end

    test "get_round_result!/1 returns the round_result with given id" do
      round_result = round_result_fixture()
      assert RoundResults.get_round_result!(round_result.id) == round_result
    end

    test "create_round_result/1 with valid data creates a round_result" do
      assert {:ok, %RoundResult{} = round_result} = RoundResults.create_round_result(@valid_attrs)
      assert round_result.cash == 42
      assert round_result.dividents == 42
      assert round_result.interest == 42
      assert round_result.shares == 42
    end

    test "create_round_result/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = RoundResults.create_round_result(@invalid_attrs)
    end

    test "update_round_result/2 with valid data updates the round_result" do
      round_result = round_result_fixture()
      assert {:ok, %RoundResult{} = round_result} = RoundResults.update_round_result(round_result, @update_attrs)
      assert round_result.cash == 43
      assert round_result.dividents == 43
      assert round_result.interest == 43
      assert round_result.shares == 43
    end

    test "update_round_result/2 with invalid data returns error changeset" do
      round_result = round_result_fixture()
      assert {:error, %Ecto.Changeset{}} = RoundResults.update_round_result(round_result, @invalid_attrs)
      assert round_result == RoundResults.get_round_result!(round_result.id)
    end

    test "delete_round_result/1 deletes the round_result" do
      round_result = round_result_fixture()
      assert {:ok, %RoundResult{}} = RoundResults.delete_round_result(round_result)
      assert_raise Ecto.NoResultsError, fn -> RoundResults.get_round_result!(round_result.id) end
    end

    test "change_round_result/1 returns a round_result changeset" do
      round_result = round_result_fixture()
      assert %Ecto.Changeset{} = RoundResults.change_round_result(round_result)
    end
  end
end
