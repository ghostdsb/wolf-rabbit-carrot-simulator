defmodule WolfRabbitCarrot.WorldServer do

  use GenServer

  alias WolfRabbitCarrot.WorldFunctions

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    :timer.send_interval(1_000, "tick")
    :timer.send_interval(60_000, "new_carrot_tick")
    WorldFunctions.plant_carrots(WolfRabbitCarrot.WorldState.__struct__().carrot_count)
    WorldFunctions.breed_rabbits(WolfRabbitCarrot.WorldState.__struct__().rabbit_count)
    WorldFunctions.breed_wolves(WolfRabbitCarrot.WorldState.__struct__().wolf_count)
    {:ok, %{tick: 0}}
  end

  def handle_info("tick", state) do
    # IO.puts("tick #{state.tick}")
    WorldFunctions.get_carrots() |> Enum.each(fn pid -> send(pid, "tick") end)
    WorldFunctions.get_rabbits() |> Enum.each(fn pid -> send(pid, "tick") end)
    WorldFunctions.get_wolves() |> Enum.each(fn pid -> send(pid, "tick") end)
    {:noreply, %{state| tick: state.tick + 1}}
  end

  def handle_info("new_carrot_tick", state) do
    WorldFunctions.plant_carrots(WolfRabbitCarrot.WorldState.__struct__().new_carrot_count)
    {:noreply, state}
  end

end
