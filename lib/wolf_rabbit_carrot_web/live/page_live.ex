defmodule WolfRabbitCarrotWeb.PageLive do
  use WolfRabbitCarrotWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    :timer.send_interval(1000, "tick")
    socket =
      socket
      |> assign(board: WolfRabbitCarrot.BoardHelper.make_board())
      |> assign(population: WolfRabbitCarrot.BoardHelper.population)
      |> assign(tick: 0)
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_info("tick", socket) do
    socket =
      socket
      |> assign(board: WolfRabbitCarrot.BoardHelper.make_board())
      |> assign(population: WolfRabbitCarrot.BoardHelper.population)
      |> assign(tick: socket.assigns.tick + 1)
    {:noreply, socket}
  end

end
