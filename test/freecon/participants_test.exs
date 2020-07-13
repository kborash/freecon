defmodule Freecon.ParticipantsTest do
  use Freecon.DataCase

  alias Freecon.Participants

  describe "participants" do
    alias Freecon.Participants.Participant

    @valid_attrs %{identifier: "7488a646-e31f-11e4-aace-600308960662", name: "some name"}
    @update_attrs %{identifier: "7488a646-e31f-11e4-aace-600308960668", name: "some updated name"}
    @invalid_attrs %{identifier: nil, name: nil}

    def participant_fixture(attrs \\ %{}) do
      {:ok, participant} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Participants.create_participant()

      participant
    end

    test "list_participants/0 returns all participants" do
      participant = participant_fixture()
      assert Participants.list_participants() == [participant]
    end

    test "get_participant!/1 returns the participant with given id" do
      participant = participant_fixture()
      assert Participants.get_participant!(participant.id) == participant
    end

    test "create_participant/1 with valid data creates a participant" do
      assert {:ok, %Participant{} = participant} = Participants.create_participant(@valid_attrs)
      assert participant.identifier == "7488a646-e31f-11e4-aace-600308960662"
      assert participant.name == "some name"
    end

    test "create_participant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Participants.create_participant(@invalid_attrs)
    end

    test "update_participant/2 with valid data updates the participant" do
      participant = participant_fixture()
      assert {:ok, %Participant{} = participant} = Participants.update_participant(participant, @update_attrs)
      assert participant.identifier == "7488a646-e31f-11e4-aace-600308960668"
      assert participant.name == "some updated name"
    end

    test "update_participant/2 with invalid data returns error changeset" do
      participant = participant_fixture()
      assert {:error, %Ecto.Changeset{}} = Participants.update_participant(participant, @invalid_attrs)
      assert participant == Participants.get_participant!(participant.id)
    end

    test "delete_participant/1 deletes the participant" do
      participant = participant_fixture()
      assert {:ok, %Participant{}} = Participants.delete_participant(participant)
      assert_raise Ecto.NoResultsError, fn -> Participants.get_participant!(participant.id) end
    end

    test "change_participant/1 returns a participant changeset" do
      participant = participant_fixture()
      assert %Ecto.Changeset{} = Participants.change_participant(participant)
    end
  end
end
