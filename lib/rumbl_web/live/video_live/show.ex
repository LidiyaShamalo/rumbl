defmodule RumblWeb.VideoLive.Show do
  use RumblWeb, :live_view

  def handle_event("new_annotation", %{"body" => body, "at" => at}, socket) do
    IO.inspect(body, label: "Пришел текст")
    IO.inspect(at, label: "Пришло время видео")

    {:noreply, socket}
  end

end
