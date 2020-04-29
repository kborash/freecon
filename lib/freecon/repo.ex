defmodule Freecon.Repo do
  use Ecto.Repo,
    otp_app: :freecon,
    adapter: Ecto.Adapters.Postgres
end
