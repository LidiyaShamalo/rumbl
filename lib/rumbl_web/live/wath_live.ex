defmodule RumblWeb.WatchLive do

  use RumblWeb, :live_view

  alias Rumbl.Accounts
  alias Rumbl.Multimedia
  alias RumblWeb.WatchHTML

  def mount(%{"id" => id_with_slug}, session, socket) do

    user_id = session["user_id"]
    current_user = if user_id, do: Accounts.get_user(user_id), else: nil

    video = Multimedia.get_video!(id_with_slug)
    topic = "video:#{video.id}"

    if connected?(socket)  && current_user do
      RumblWeb.Endpoint.subscribe(topic)
      IO.puts "ПОДПИСКА ОФОРМЛЕНА НА ТОПИК: #{topic}"

      {:ok, _} = RumblWeb.Presence.track(self(), topic, current_user.id, %{
        username: current_user.username,
        online_at: inspect(System.system_time(:second))
      })
    end

    initial_users =
    if connected?(socket),
      do: list_online_users(topic),
      else: []

    {:ok,
      socket
      |> assign(:video, video)
      |> assign(:topic, topic)
      |> assign(:current_user, current_user)
      |> assign(:user_list, initial_users)
      |> stream(:messages, [])
    }
  end

  def handle_event("new_annotation", %{"body" => body, "at" => at}, socket) do
    if socket.assigns.current_user do
      case Multimedia.annotate_video(socket.assigns.current_user, socket.assigns.video.id, %{body: body, at: at}) do
        {:ok, annotation} ->
          annotation = Rumbl.Repo.preload(annotation, :user)

          RumblWeb.Endpoint.broadcast!(socket.assigns.topic, "new_annotation", %{
            id: annotation.id,
            user: RumblWeb.UserJSON.data_show(socket.assigns.current_user),
            body: annotation.body,
            at: annotation.at
        })
            # socket.assigns.topic, "new_annotation", annotation)
          {:noreply, stream_insert(socket, :messages, annotation)} #socket}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Не удалось сохранить комментарий")}
      end
    else
      {:noreply, put_flash(socket, :error, "Войдите в систему, чтобы оставить комментарий")}
    end
  end

  # стандартный
  def handle_event("player_tick", %{"at" => at}, socket) do
    annotations = Multimedia.list_annotations_at(socket.assigns.video, at)
    socket = Enum.reduce(annotations, socket, fn ann, acc ->
      stream_insert(acc, :messages, ann)
    end)

    {:noreply, socket}
end

def handle_event("seek", %{"at" => at}, socket) do
  socket =
    socket

    |> stream(:messages, [], reset: true)
    |> push_event("seek", %{at: at})

  {:noreply, socket}
end

# перемотка
def handle_event("player_rewind", %{"at" => at}, socket) do
  past_annotations = Multimedia.list_annotations_past(socket.assigns.video, at)
  {:noreply, stream(socket, :messages, past_annotations, reset: true)}
end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "new_annotation"}, socket) do
    IO.puts "ПОЛУЧЕНО ЧЕРЕЗ BROADCAST"
    {:noreply, socket}
  end

  # Когда состав участников меняется
  def handle_info(%{event: "presence_diff"}, socket) do
    users = list_online_users(socket.assigns.topic) #!!!!!!!!!!!!!

    # |> Enum.map(fn {_id, %{metas: [%{username: username} | _]}} -> username end)

    {:noreply, assign(socket, :user_list, users)}
  end

  def render(assigns) do
    ~H"""
      <WatchHTML.show
        video={@video}
        messages={@streams.messages}
        current_user={@current_user}
        user_list={@user_list}
      />
    """
  end


  defp list_online_users(topic) do
    RumblWeb.Presence.list(topic)
    |> Enum.map(fn {_id, %{metas: [%{username: username} | _]}} ->
      username
    end)
  end
end
