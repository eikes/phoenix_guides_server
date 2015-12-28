defmodule PhoenixGuidesServer.PageControllerTest do
  use PhoenixGuidesServer.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Productive. Reliable. Fast."
  end
end
