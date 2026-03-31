defmodule RumblWeb.WatchHTML do
  use RumblWeb, :html

  embed_templates "watch_html/*"

  attr :video, Rumbl.Multimedia.Video, required: true
  attr :current_user, :any, default: nil
  attr :messages, :list, required: true

  def show(assigns)

  def player_id(video) do
  #   ~r{^.*(?:youtu\.be/|\w+/|v=)(?<id>[^#&?]*)}
  #   |> Regex.named_captures(video.url)
  #   |> get_in(["id"])
  # end
    ~r/^.*(?:outu\.be\/|v\/|u\/\w\/|embed\/|watch\?v=|\&v=)([^#\&\?]*).*/

      |> Regex.run(video.url)
      |> case do
        [_, id] -> id
        _ -> nil
    end
  end

end
