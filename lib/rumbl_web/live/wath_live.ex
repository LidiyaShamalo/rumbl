defmodule RumblWeb.WatchLive do
  use RumblWeb, :live_view
  alias Rumbl.Multimedia
  alias RumblWeb.WatchHTML

  def mount(%{"id" => id}, _session, socket) do
    video = Multimedia.get_video!(id)
    {:ok, assign(socket, video: video, messages: [])}
  end

  def handle_event("new_annotation", %{"body" => body, "at" => at}, socket) do
    IO.puts "--- МЫ ПОЙМАЛИ СОБЫТИЕ! ---"
    IO.inspect(body, label: "Текст сообщения")
    IO.inspect(at, label: "Время в видео (мс)")

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <WatchHTML.show video={@video} />
    """
  end
end
