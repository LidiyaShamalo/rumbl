defmodule RumblWeb.WatchLive do
  use RumblWeb, :live_view
  alias Rumbl.Multimedia
  alias RumblWeb.WatchHTML

  def mount(%{"id" => id}, _session, socket) do
    video = Multimedia.get_video!(id)
    topic = "video:#{id}"

    if connected?(socket) do
      RumblWeb.Endpoint.subscribe(topic)
    end

    {:ok, assign(socket, video: video, topic: topic, messages: [])}
  end

  def handle_event("new_annotation", %{"body" => body, "at" => at}, socket) do
    IO.puts "--- МЫ ПОЙМАЛИ СОБЫТИЕ! ---"
    IO.inspect(body, label: "Текст сообщения")
    IO.inspect(at, label: "Время в видео (мс)")


    result = Multimedia.annotate_video(socket.assigns.current_user, socket.assigns.video, %{body: body, at: at})

    new_msg = %{body: body, at: at, user: %{username: "Аноним"}}

    RumblWeb.Endpoint.broadcast!(socket.assigns.topic, "new_annotation", new_msg)

    {:noreply, socket}
  end

  def handle_info(%{event: "new_annotation", payload: msg}, socket) do
  # Добавляем новое сообщение в начало списка
  updated_messages = [msg | socket.assigns.messages]
  {:noreply, assign(socket, messages: updated_messages)}
end

  def render(assigns) do
    ~H"""
    <WatchHTML.show video={@video} />
    """
  end
end
