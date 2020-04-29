defmodule Freecon.Accounts.Professor do
  use Ecto.Schema
  import Ecto.Changeset

  alias Freecon.Accounts.Professor

  schema "professors" do
    field :name, :string
    field :email, :string
    field :active, :boolean, default: true
    field :encrypted_password, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  def changeset(%Professor{}=professor, attrs) do
    professor
    |> cast(attrs, [:name, :email, :active, :password, :password_confirmation])
    |> validate_confirmation(:password, message: "Passwords do not match.")
    |> encrypt_password()
    |> validate_format(:email, ~r/@.*\./)
    |> validate_required([:name, :email, :active, :password, :password_confirmation])
    |> unique_constraint(:email, message: "This username is unavailable.")
  end

  def encrypt_password(changeset) do
    with password when not is_nil(password) <- get_change(changeset, :password) do
      put_change(changeset, :encrypted_password, Argon2.hash_pwd_salt(password))
    else
      _ -> changeset
    end
  end
end