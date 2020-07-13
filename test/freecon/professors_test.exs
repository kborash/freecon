defmodule Freecon.ProfessorsTest do
  use Freecon.DataCase

  alias Freecon.Professors

  describe "professors" do
    alias Freecon.Professors.Professor

    @valid_attrs %{active: true, email: "some email", encrypted_password: "some encrypted_password", name: "some name"}
    @update_attrs %{active: false, email: "some updated email", encrypted_password: "some updated encrypted_password", name: "some updated name"}
    @invalid_attrs %{active: nil, email: nil, encrypted_password: nil, name: nil}

    def professor_fixture(attrs \\ %{}) do
      {:ok, professor} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Professors.create_professor()

      professor
    end

    test "list_professors/0 returns all professors" do
      professor = professor_fixture()
      assert Professors.list_professors() == [professor]
    end

    test "get_professor!/1 returns the professor with given id" do
      professor = professor_fixture()
      assert Professors.get_professor!(professor.id) == professor
    end

    test "create_professor/1 with valid data creates a professor" do
      assert {:ok, %Professor{} = professor} = Professors.create_professor(@valid_attrs)
      assert professor.active == true
      assert professor.email == "some email"
      assert professor.encrypted_password == "some encrypted_password"
      assert professor.name == "some name"
    end

    test "create_professor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Professors.create_professor(@invalid_attrs)
    end

    test "update_professor/2 with valid data updates the professor" do
      professor = professor_fixture()
      assert {:ok, %Professor{} = professor} = Professors.update_professor(professor, @update_attrs)
      assert professor.active == false
      assert professor.email == "some updated email"
      assert professor.encrypted_password == "some updated encrypted_password"
      assert professor.name == "some updated name"
    end

    test "update_professor/2 with invalid data returns error changeset" do
      professor = professor_fixture()
      assert {:error, %Ecto.Changeset{}} = Professors.update_professor(professor, @invalid_attrs)
      assert professor == Professors.get_professor!(professor.id)
    end

    test "delete_professor/1 deletes the professor" do
      professor = professor_fixture()
      assert {:ok, %Professor{}} = Professors.delete_professor(professor)
      assert_raise Ecto.NoResultsError, fn -> Professors.get_professor!(professor.id) end
    end

    test "change_professor/1 returns a professor changeset" do
      professor = professor_fixture()
      assert %Ecto.Changeset{} = Professors.change_professor(professor)
    end
  end
end
