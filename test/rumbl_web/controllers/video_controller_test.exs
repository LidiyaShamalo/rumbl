defmodule RumblWeb.VideoControllerTest do
  use RumblWeb.ConnCase, async: true

  alias Rumbl.Multimedia

  @create_attrs %{
    description: "some description",
    title: "vid",
    url: "http://youtu.be"
  }
  # @update_attrs %{description: "some updated description", title: "some updated title", url: "some updated url"}
  @invalid_attrs %{
    description: nil,
    title: "invalid",
    url: nil
  }

  defp video_count, do: Enum.count(Multimedia.list_videos())

  test "requires user authentication on all actions", %{conn: conn} do
    actions = [
      get(conn, ~p"/manage/videos/new"),                #new
      get(conn, ~p"/manage/videos"),                    #index
      get(conn, ~p"/manage/videos/123"),                #show
      get(conn, ~p"/manage/videos/123/edit"),           #edit
      put(conn, ~p"/manage/videos/123", video: %{}),    #update
      post(conn, ~p"/manage/videos", video: %{}),       #create
      delete(conn, ~p"/manage/videos/123")              #delete
    ]

    Enum.each(actions, fn conn ->

    assert html_response(conn, 302)
      assert conn.halted
    end)
  end

  describe "with a logged-in user" do

    setup %{conn: conn, login_as: username} do
      user = user_fixture(username: username)
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    @tag login_as: "max"
    test "lists all user's videos on index", %{conn: conn, user: user} do
      user_video = video_fixture(user, title: "funny cats")
      other_video = video_fixture(
        user_fixture(username: "other"),
        title: "another video"
      )

      conn = get conn, ~p"/manage/videos"
      assert html_response(conn, 200) =~ ~r/Listing Videos/
      assert String.contains?(conn.resp_body, user_video.title)
      refute String.contains?(conn.resp_body, other_video.title)
    end
  end

  @tag login_as: "max"
  test "creates user  video and redirects", %{conn: conn, user: user} do
      create_conn = post conn, ~p"/manage/videos", video: @create_attrs

      assert %{id: id} = redirected_params(create_conn)
      assert redirected_to(create_conn) == ~p"/manage/videos/#{id}"

      conn = get conn, ~p"/manage/videos/#{id}"
      assert html_response(conn, 200) =~ "Show Video"

      assert Multimedia.get_video!(id).user_id == user.id
    end

    @tag login_as: "max"
    test "does not create video and renders errors when invalid", %{conn: conn} do
      count_before = video_count()
      conn = post conn, ~p"/manage/videos", video: @invalid_attrs
      assert html_response(conn, 200) =~ "check the errors"
      assert video_count() == count_before
    end
  


  # describe "index" do
  #   test "lists all videos", %{conn: conn} do
  #     conn = get(conn, ~p"/videos")
  #     assert html_response(conn, 200) =~ "Listing Videos"
  #   end
  # end

  # describe "new video" do
  #   test "renders form", %{conn: conn} do
  #     conn = get(conn, ~p"/videos/new")
  #     assert html_response(conn, 200) =~ "New Video"
  #   end
  # end

  # describe "create video" do
  #   test "redirects to show when data is valid", %{conn: conn} do
  #     conn = post(conn, ~p"/videos", video: @create_attrs)

  #     assert %{id: id} = redirected_params(conn)
  #     assert redirected_to(conn) == ~p"/videos/#{id}"

  #     conn = get(conn, ~p"/videos/#{id}")
  #     assert html_response(conn, 200) =~ "Video #{id}"
  #   end

  #   test "renders errors when data is invalid", %{conn: conn} do
  #     conn = post(conn, ~p"/videos", video: @invalid_attrs)
  #     assert html_response(conn, 200) =~ "New Video"
  #   end
  # end

  # describe "edit video" do
  #   setup [:create_video]

  #   test "renders form for editing chosen video", %{conn: conn, video: video} do
  #     conn = get(conn, ~p"/videos/#{video}/edit")
  #     assert html_response(conn, 200) =~ "Edit Video"
  #   end
  # end

  # describe "update video" do
  #   setup [:create_video]

  #   test "redirects when data is valid", %{conn: conn, video: video} do
  #     conn = put(conn, ~p"/videos/#{video}", video: @update_attrs)
  #     assert redirected_to(conn) == ~p"/videos/#{video}"

  #     conn = get(conn, ~p"/videos/#{video}")
  #     assert html_response(conn, 200) =~ "some updated url"
  #   end

  #   test "renders errors when data is invalid", %{conn: conn, video: video} do
  #     conn = put(conn, ~p"/videos/#{video}", video: @invalid_attrs)
  #     assert html_response(conn, 200) =~ "Edit Video"
  #   end
  # end

  # describe "delete video" do
  #   setup [:create_video]

  #   test "deletes chosen video", %{conn: conn, video: video} do
  #     conn = delete(conn, ~p"/videos/#{video}")
  #     assert redirected_to(conn) == ~p"/videos"

  #     assert_error_sent 404, fn ->
  #       get(conn, ~p"/videos/#{video}")
  #     end
  #   end
  # end

  # defp create_video(_) do
  #   video = video_fixture()

  #   %{video: video}
  # end
end
