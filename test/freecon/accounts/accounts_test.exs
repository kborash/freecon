defmodule Freecon.AccountsTest do
  use Freecon.DataCase

  alias Freecon.Accounts

  describe "professors" do
    @valid_attrs %{
      name: "Dr. Test User",
      email: "test@example.com",
      active: true,
      password: "test",
      password_confirmation: "test"
    }

    def professor_fixture(attrs \\ %{}) do
      with create_attrs <- Map.merge(@valid_attrs, attrs),
           {:ok, professor} <- Accounts.create_professor(create_attrs) do
        professor
        |> Map.merge(%{password: nil, password_confirmation: nil})
      end
    end

    test "list_professors/0 returns all professors" do
      professor = professor_fixture()

      assert Accounts.list_professors() == [professor]
    end

    test "new_professor/0 returns a blank changeset" do
      changeset = Accounts.new_professor()

      assert changeset.__struct__ == Ecto.Changeset
    end

    test "create_professor/1 saves the new user to the db and returns it" do
      before_list = Accounts.list_professors()
      professor = professor_fixture()
      after_list = Accounts.list_professors()
      assert !Enum.any?(before_list, fn p -> professor == p end)
      assert Enum.any?(after_list, fn p -> professor == p end)
    end

    test "create_professor/1 fails with an invalid email" do
      {:error, changeset} = professor_fixture(%{email: "totallyfake"})
      assert !changeset.valid?
    end

    test "create_professor/1 fails without a password" do
      {:error, changeset} = professor_fixture(%{password: nil, password_confirmation: nil})
      assert !changeset.valid?
    end

    test "create_professor/1 fails with mismatched passwords" do
      {:error, changeset} = professor_fixture(%{password: "test", password_confirmation: "wrong"})
      assert !changeset.valid?
    end

    test "create_professor/1 fails with a duplicate email" do
      _professor = professor_fixture()
      {:error, duplicate_email_professor} = professor_fixture()
      assert !duplicate_email_professor.valid?
    end
  end
end