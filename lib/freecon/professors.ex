defmodule Freecon.Professors do
  @moduledoc """
  The Professors context.
  """

  import Ecto.Query, warn: false
  alias Freecon.Repo

  alias Freecon.Professors.Professor

  @doc """
  Returns the list of professors.

  ## Examples

      iex> list_professors()
      [%Professor{}, ...]

  """
  def list_professors do
    Repo.all(Professor)
  end

  @doc """
  Gets a single professor.

  Raises `Ecto.NoResultsError` if the Professor does not exist.

  ## Examples

      iex> get_professor!(123)
      %Professor{}

      iex> get_professor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_professor!(id), do: Repo.get!(Professor, id)

  @doc """
  Creates a professor.

  ## Examples

      iex> create_professor(%{field: value})
      {:ok, %Professor{}}

      iex> create_professor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_professor(attrs \\ %{}) do
    %Professor{}
    |> Professor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a professor.

  ## Examples

      iex> update_professor(professor, %{field: new_value})
      {:ok, %Professor{}}

      iex> update_professor(professor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_professor(%Professor{} = professor, attrs) do
    professor
    |> Professor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a professor.

  ## Examples

      iex> delete_professor(professor)
      {:ok, %Professor{}}

      iex> delete_professor(professor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_professor(%Professor{} = professor) do
    Repo.delete(professor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking professor changes.

  ## Examples

      iex> change_professor(professor)
      %Ecto.Changeset{data: %Professor{}}

  """
  def change_professor(%Professor{} = professor, attrs \\ %{}) do
    Professor.changeset(professor, attrs)
  end

  def get_professor_by_email(email) do
    Repo.get_by(Professor, email: email)
  end
end
