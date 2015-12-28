defmodule PhoenixGuidesServer.PageController do
  use PhoenixGuidesServer.Web, :controller

  def index(conn, _params) do
    conn
    |> assign(:page, nil)
    |> assign(:tags, nil)
    |> render "index.html"
  end

  def docs(conn, %{"path" => path}) do
    menu = Application.get_all_env(:docs_menu)
    page = get_page_dict_from_menu(menu, path)
    tag = get_tag(conn)
    file_content = get_file_content page[:file], tag

    conn
    |> assign(:menu, menu)
    |> assign(:content, Earmark.to_html(file_content))
    |> assign(:page, page)
    |> assign(:tag, tag)
    |> assign(:tags, get_all_tags())
    |> render "doc.html"
  end

  defp get_page_dict_from_menu(menu, path) do
    menu[:topics]
    |> Enum.map(fn(topic) -> topic[:documents] end)
    |> Enum.reduce(fn(page_array, acc) -> Enum.concat(page_array, acc) end)
    |> Enum.filter(fn(page) -> page[:url] == path end)
    |> List.first
  end

  defp get_file_content(file, tag) do
    # System.cmd("cat", ["phoenix_guides/" <> file]) |> elem(0)
    git_cmd(["show", tag <> ":" <> file])
  end

  defp git_cmd(args) do
    System.cmd("git", ["--work-tree=phoenix_guides", "--git-dir=phoenix_guides/.git"] ++ args)
    |> elem(0)
  end

  def get_tag(conn) do
    tag = conn.params["tag"]
    if is_nil(tag) do
      tag = "HEAD"
    end
    tag
  end

  defp get_all_tags() do
    git_cmd(["tag", "--sort=v:refname"])
    |> String.split("\n")
    |> Enum.reject(fn(tag) -> tag == "" end)
  end

end
