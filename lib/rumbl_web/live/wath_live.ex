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

    if connected?(socket) do
      RumblWeb.Endpoint.subscribe(topic)
      IO.puts "ПОДПИСКА ОФОРМЛЕНА НА ТОПИК: #{topic}"
    end

      annotations =
        video

        |> Multimedia.list_annotations()
        |> Enum.map(&RumblWeb.AnnotationJSON.data/1)

    {:ok,
      socket
      |> assign(:video, video)
      |> assign(:topic, topic)
      |> assign(:current_user, current_user)
      |> stream(:messages, annotations)

    }
  end

  def handle_event("new_annotation", %{"body" => body, "at" => at}, socket) do
    IO.puts "--- МЫ ПОЙМАЛИ СОБЫТИЕ! ---"
    IO.inspect(body, label: "Текст сообщения")
    IO.inspect(at, label: "Время в видео (мс)")

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
          {:noreply, socket}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Не удалось сохранить комментарий")}
      end
    else
      {:noreply, put_flash(socket, :error, "Войдите в систему, чтобы оставить комментарий")}
    end


  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "new_annotation", payload: msg}, socket) do
  # Добавляем новое сообщение в начало списка
  #updated_messages = [msg | socket.assigns.messages]
  IO.puts "ПОЛУЧЕНО ЧЕРЕЗ BROADCAST"
  {:noreply, assign(socket, messages: [msg])}
end

def handle_info(%{event: "new_annotation", payload: msg}, socket) do
  IO.puts "ПОЛУЧЕНО НАПРЯМУЮ"
  {:noreply, stream_insert(socket, :messages, msg)}
end

  def render(assigns) do
    ~H"""
      <WatchHTML.show
        video={@video}
        messages={@streams.messages}
        current_user={@current_user}
      />
    """
  end
end
