defmodule FreeconWeb.ProfessorController do
  use FreeconWeb, :controller
  alias Freecon.Professors
  alias Freecon.Professors.Professor

  def new(conn, _) do
    professor = Professors.change_professor(%Professor{})

    conn
    |> render("new.html", professor: professor)
  end

  def create(conn, %{"professor" => professor_params}) do
    with {:ok, professor} <- Professors.create_professor(professor_params) do
      conn
      |> put_flash(:info, "Account created!")
      |> put_session(:professor, %{ id: professor.id, email: professor.email})
      |> redirect(to: Routes.live_path(conn, FreeconWeb.ProfessorDashboard))
    else
      {:error, professor} ->
        conn
        |> put_flash(:error, "Failed to create account.")
        |> render("new.html", professor: professor)
    end
  end
end