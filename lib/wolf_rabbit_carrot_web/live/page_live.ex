defmodule WolfRabbitCarrotWeb.PageLive do
  use WolfRabbitCarrotWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    :timer.send_interval(1000, "tick")
    socket =
      socket
      |> assign(board: WolfRabbitCarrot.BoardHelper.make_board())
      |> assign(population: WolfRabbitCarrot.BoardHelper.population)
      |> assign(carrots: WolfRabbitCarrot.WorldFunctions.get_carrots())
      # |> assign(rabbits: WolfRabbitCarrot.WorldFunctions.get_rabbits())
      # |> assign(wolves: WolfRabbitCarrot.WorldFunctions.get_wolves())
      |> assign(rabbits: WolfRabbitCarrot.BoardHelper.rabbit_data())
      |> assign(wolves: WolfRabbitCarrot.BoardHelper.wolf_data())
      |> assign(tick: 0)
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_info("tick", socket) do
    WolfRabbitCarrot.BoardHelper.rabbit_data() |> IO.inspect()
    socket =
      socket
      |> assign(board: WolfRabbitCarrot.BoardHelper.make_board())
      |> assign(population: WolfRabbitCarrot.BoardHelper.population)
      |> assign(carrots: WolfRabbitCarrot.WorldFunctions.get_carrots())
      |> assign(rabbits: WolfRabbitCarrot.BoardHelper.rabbit_data())
      |> assign(wolves: WolfRabbitCarrot.BoardHelper.wolf_data())
      # |> assign(rabbits: WolfRabbitCarrot.WorldFunctions.get_rabbits())
      # |> assign(wolves: WolfRabbitCarrot.WorldFunctions.get_wolves())
      |> assign(tick: socket.assigns.tick + 1)
    {:noreply, socket}
  end

end
