defmodule FreeconWeb.ProfessorController do
  use FreeconWeb, :controller
  alias Freecon.Accounts

  def new(conn, _) do
    professor = Accounts.new_professor()

    conn
    |> render("new.html", professor: professor)
  end

  def create(conn, %{"professor" => professor_params}) do
    with {:ok, professor} <- Accounts.create_professor(professor_params) do
      conn
      |> put_flash(:info, "Account created!")
      |> redirect(to: "/")
    else
      {:error, professor} ->
        conn
        |> put_flash(:error, "Failed to create account.")
        |> render("new.html", professor: professor)
    end
  end
end