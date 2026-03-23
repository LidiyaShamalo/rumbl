defmodule RumblWeb.Auth do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Rumbl.Accounts.get_user(user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  #удаление всех сессии в конце запроса
  #Это считается более безопасным способом для выхода из системы (Log out).
  #Это гарантирует, что никакие старые данные не «подмешаются» новому пользователю,
  #если он зайдет за тот же компьютер
  def logout(conn) do
    configure_session(conn, drop: true)
  end

  #удаление только информации о пользователе, когда нужно просто разлогинить пользователя,
  # #но не ломать его текущий сеанс работы с сайтом
  # def logout(conn) do
  #   delete_session(conn, :user_id)
  # end

end
