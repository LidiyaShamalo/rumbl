defmodule RumblWeb.VideoHTML do
  use RumblWeb, :html

  embed_templates "video_html/*"

  @doc """
  Renders a video form.

  The form is defined in the template at
  video_html/video_form.html.heex
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true
  attr :return_to, :string, default: nil

  def video_form(assigns)
end
