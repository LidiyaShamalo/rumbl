defmodule RumblWeb.AuthTest do
  use RumblWeb.ConnCase, async: true
  alias RumblWeb.Auth

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])

    assert conn.halted
    assert redirected_to(conn) == ~p"/"
  end

  test "authenticate_user for existing current_user", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Rumbl.Accounts.User{})
      |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    login_conn = Auth.login(conn, %Rumbl.Accounts.User{id: 123})

    assert get_session(login_conn, :user_id) == 123
    assert login_conn.assigns.current_user.id == 123
  end

  test "logout drops the session", %{conn: conn} do
    logout_conn =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()

    assert logout_conn.private.plug_session_info == :drop

    assert logout_conn.private.plug_session_fetch == :done
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = user_fixture()
    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Auth.init([]))

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assign to nil", %{conn: conn} do
    conn = Auth.call(conn, Auth.init([]))
    assert conn.assigns.current_user == nil
  end
end
