defmodule RumblWeb.UserController do
  use RumblWeb, :controller

  alias Rumbl.Accounts

  @spec index(Plug.Conn.t(), any()) :: Plug.Conn.t()
  def index(conn, _params) do
    case authenticate(conn) do
      %Plug.Conn{halted: true} = conn ->
        conn
      conn ->
        users = Accounts.list_users()
        render(conn, :index, users: users)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)

    render(conn, :show, user: user)
  end

  def new(conn, _params) do
    changeset =  Accounts.change_registration(%Accounts.User{}, %{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: ~p"/users")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  defp authenticate(conn) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: ~p"/")
      |> halt()
    end
  end
end
