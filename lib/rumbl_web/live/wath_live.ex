defmodule RumblWeb.WatchLive do
  use RumblWeb, :live_view

  alias Rumbl.Accounts
  alias Rumbl.Multimedia
  alias RumblWeb.WatchHTML

  def mount(%{"id" => id}, session, socket) do

    user_id = session["user_id"]
    current_user = if user_id, do: Accounts.get_user(user_id), else: nil

    video = Multimedia.get_video!(id)
    topic = "video:#{id}"

    if connected?(socket) do
      RumblWeb.Endpoint.subscribe(topic)
    end

    {:ok,
      socket
      |> assign(:video, video)
      |> assign(:topic, topic)
      |> assign(:messages, [])
      |> assign(:current_user, current_user)
    }
  end

  def handle_event("new_annotation", %{"body" => body, "at" => at}, socket) do
    IO.puts "--- МЫ ПОЙМАЛИ СОБЫТИЕ! ---"
    IO.inspect(body, label: "Текст сообщения")
    IO.inspect(at, label: "Время в видео (мс)")

    case Multimedia.annotate_video(socket.assigns.current_user, socket.assigns.video.id, %{body: body, at: at}) do
      {:ok, annotation} ->
        annotation = Rumbl.Repo.preload(annotation, :user)
        RumblWeb.Endpoint.broadcast!(socket.assigns.topic, "new_annotation", %{
          id: annotation.id,
          user: RumblWeb.UserJSON.show(%{user: socket.assigns.current_user}),
          body: annotation.body,
          at: annotation.at
      })
          # socket.assigns.topic, "new_annotation", annotation)
        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Не удалось сохранить комментарий")}
    end
  end

  def handle_info(%{event: "new_annotation", payload: msg}, socket) do
  # Добавляем новое сообщение в начало списка
  updated_messages = [msg | socket.assigns.messages]
  {:noreply, assign(socket, messages: updated_messages)}
end

  def render(assigns) do
    ~H"""
      <WatchHTML.show video={@video} messages={@messages}/>
    """
  end
end
