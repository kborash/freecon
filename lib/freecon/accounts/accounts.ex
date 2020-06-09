defmodule Freecon.Accounts do
  import Ecto.Query, warn: false

  alias Freecon.Repo
  alias Freecon.Accounts.Professor

  def list_professors, do: Repo.all(Professor)

  def new_professor, do: Professor.changeset(%Professor{}, %{})

  def create_professor(attrs \\ %{}) do
    %Professor{}
    |> Professor.changeset(attrs)
    |> Repo.insert
  end

  def get_professor(id), do: Repo.get(Professor, id)

  def get_professor_by_email(email) do
    Repo.get_by(Professor, email: email)
  end
end