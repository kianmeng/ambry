defmodule AmbryWeb.LibraryLive.Home.RecentBooks do
  @moduledoc false

  use AmbryWeb, :live_component

  alias Ambry.Books

  @limit 25

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> load_books()}
  end

  @impl Phoenix.LiveComponent
  def handle_event("load-more", _params, socket) do
    {:noreply, load_books(socket)}
  end

  defp load_books(%{assigns: assigns} = socket) do
    current_page = Map.get(assigns, :current_page, 0)
    books = Map.get(assigns, :books, [])
    offset = Map.get(assigns, :offset, 0)
    {more_books, has_more?} = Books.get_recent_books(offset, @limit)
    books = books ++ more_books

    socket
    |> assign(:current_page, current_page + 1)
    |> assign(:books, books)
    |> assign(:offset, offset + @limit)
    |> assign(:show_load_more?, has_more?)
  end
end
