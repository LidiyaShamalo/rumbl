defmodule RumblWeb.AnnotationJSON do
  def index(%{annotations: annotations}) do
    %{data: Enum.map(annotations, &data/1)}
  end

  def data(annotation) do
    %{
      id: annotation.id,
      body: annotation.body,
      at: annotation.at,
      user: RumblWeb.UserJSON.data_show(annotation.user)
    }
  end
end
