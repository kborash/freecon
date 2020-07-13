defmodule Freecon.Professors.Professor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "professors" do
    field :active, :boolean, default: false
    field :email, :string
    field :encrypted_password, :string
    field :name, :string

    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    timestamps()
  end

  @doc false
  def changeset(professor, attrs) do
    professor
    |> cast(attrs, [:name, :email, :encrypted_password, :active, :password, :password_confirmation])
    |> encrypt_password()
    |> validate_confirmation(:password, message: "Passwords do not match.")
    |> validate_format(:email, ~r/@.*\./)
    |> validate_required([:name, :email, :encrypted_password, :active, :password, :password_confirmation])
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
