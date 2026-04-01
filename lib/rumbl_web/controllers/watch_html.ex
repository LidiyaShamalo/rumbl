defmodule RumblWeb.WatchHTML do
  use RumblWeb, :html

  embed_templates "watch_html/*"

  attr :video, Rumbl.Multimedia.Video, required: true
  attr :current_user, :any, default: nil
  attr :messages, :list, required: true

  def show(assigns)

  def player_id(video) do
    ~r/^.*(?:outu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/

      |> Regex.run(video.url)
      |> case do
        [_, id] -> id
        _ -> nil
    end
  end

  def format_time(at) do
    at
    |> div(1000)
    |>Time.from_seconds_after_midnight()
    |> Calendar.strftime("%M:%S")
  end

end
