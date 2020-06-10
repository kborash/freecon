defmodule FreeconWeb.VerifyParticipantSession do
  import Plug.Conn, only: [get_session: 2, halt: 1]
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case get_session(conn, :participant) do
      nil ->
        conn
        |> put_flash(:error, "You must log in as a participant to do that!")
        |> redirect(to: "/")
        |> halt()
      _ -> conn
    end
  end
end