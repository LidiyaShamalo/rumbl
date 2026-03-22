defmodule Rumbl.Accounts do
  @moduledoc """
  The Accounts context.
  """
  alias Rumbl.Repo
  alias Rumbl.Accounts.User

  @spec get_user(integer()) :: User.t() | nil
  def get_user(id) do
    Repo.get(User, id)
  end

  @spec get_user!(integer()) :: User.t()
  def get_user!(id) do
    Repo.get!(User, id)
  end

  @spec get_user_by(list() | map()) :: User.t() | nil
  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  @spec list_users() :: [User.t()]
  def list_users do
    Repo.all(User)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
end
