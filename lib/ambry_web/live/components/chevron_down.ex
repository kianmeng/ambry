defmodule AmbryWeb.Components.ChevronDown do
  @moduledoc """
  Heroicons chevron-down 24x24
  """

  use AmbryWeb, :component

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~F"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      class="h-6 w-6"
      fill="none"
      viewBox="0 0 24 24"
      stroke="currentColor"
    >
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
    </svg>
    """
  end
end
