defmodule RumblWeb.PageController do
  use RumblWeb, :controller

  def home(conn, _params) do
    conn
    |> put_layout(html: {RumblWeb.Layouts, :app})
    |> render(:home)
  end
end
