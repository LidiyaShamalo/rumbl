defmodule RumblWeb.AuthTest do
  use RumblWeb.ConnCase, async: true
  alias RumblWeb.Auth

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])

    assert conn.halted
    # assert redirected_to(conn) == ~p"/"
  end

  test "authenticate_user for existing current_user", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %Rumbl.Accounts.User{})
      |> Auth.authenticate_user([])

    refute conn.halted
  end


end
