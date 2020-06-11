defmodule FreeconWeb.ProfessorDashboard do
  use FreeconWeb, :live_view

  alias Freecon.Experiments

  def mount(_params, _session, socket) do
    socket = assign(
      socket,
      bob: "1"
    )
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1 class="text-5xl">A great dashboard!</h1>
    """
  end
end