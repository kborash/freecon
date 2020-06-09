defmodule FreeconWeb.SessionController do
  use FreeconWeb, :controller
  alias Freecon.Accounts

  def new(conn, _) do
    conn
    |> render("new.html")
  end

  def delete(conn, _) do
    conn
    |> delete_session(:professor)
    |> put_flash(:info, "Logged out successfully!")
    |> redirect(to: "/")
  end

  def create(conn, %{"email" => email, "password" => password}) do
    with professor <- Accounts.get_professor_by_email(email),
         {:ok, login_professor} <- login(professor, password)
    do
      conn
      |> put_flash(:info, "Logged in successfully!")
      |> put_session(:professor, %{ id: login_professor.id, email: login_professor.email})
      |> redirect(to: "/")
    else
      {:error, _} ->
        conn
        |> put_flash(:error, "Invalid credentials.")
        |> render("new.html")
    end
  end

  defp login(professor, password) do
    Argon2.check_pass(professor, password)
  end
end