defmodule RumblWeb.UserJSON do
  def show(%{user: user}) do
    %{data: data_show(user)}
  end

  def data_show(user) do
    %{
      id: user.id,
      username: user.username
    }
  end
end
