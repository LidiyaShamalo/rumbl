defmodule RumblWeb.VideoHtmlTest do
  use RumblWeb.ConnCase, async: true
  alias RumblWeb.VideoHTML

  import Phoenix.LiveViewTest

  test "category_select_options/1 convers categories to name-id tuples" do
    categories = [
      %{name: "Drama", id: 1},
      %{name: "Action", id: 2}
    ]

    assert VideoHTML.category_select_options(categories) == [{"Drama", 1}, {"Action", 2}]
  end

  test "render video_form.html" do
    changeset = Ecto.Changeset.change(%Rumbl.Multimedia.Video{})
    categories = [%{name: "Drama", id: 1}]

    html = render_component(&VideoHTML.video_form/1, %{
      changeset: changeset,
      action: "/manage/videos",
      categories: categories,
      return_to: nil
    })

    assert html =~ "Save Video"
    assert html =~ "1"
    assert html =~ "Drama"
    assert html =~ "action=\"/manage/videos\""

  end

  test "renders new template" do
    changeset = Ecto.Changeset.change(%Rumbl.Multimedia.Video{})
    categories = []

    html = render_component(&VideoHTML.new/1, %{
      changeset: changeset,
      categories: categories
    })

    assert html =~ "New Video"
    assert html =~ "Save Video"
  end

  test "renders edit template" do
    video = %Rumbl.Multimedia.Video{id: 4, title: "Old title"}
    changeset = Ecto.Changeset.change(video)
    categories = []

    html = render_component(&VideoHTML.edit/1, %{
      video: video,
      changeset: changeset,
      categories: categories
    })

    assert html =~ "Edit Video 4"
    assert html =~ "Old title"
  end

  test "renders show video" do
    video = %Rumbl.Multimedia.Video{id: 4, title: "Phoenix Guide", url: "http://phx.com"}

    html = render_component(&VideoHTML.show/1, %{video: video})

    assert html =~ "Video 4"
    assert html =~ "Phoenix Guide"
    assert html =~ "Edit video"
  end

  test "renders index with videos" do
    videos = [%Rumbl.Multimedia.Video{id: 1, title: "Elixir Tutorial", url: "http://ex.com"}]

    html = render_component(&VideoHTML.index/1, %{videos: videos})

    assert html =~ "Listing Videos"
    assert html =~ "Elixir Tutorial"
    assert html =~ "http://ex.com"
    assert html =~ "/manage/videos/1/edit"
  end
end
