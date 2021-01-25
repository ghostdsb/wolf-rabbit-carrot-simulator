defmodule WolfRabbitCarrot.WolfEntity do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: :"wolf#{DateTime.utc_now() |> DateTime.to_iso8601()}")
  end

  def get_position(pid) do
    GenServer.call(pid, "get_position")
  end

  def init([]) do
    state =
      WolfRabbitCarrot.AnimalState.__struct__()
      |> Map.put(:direction, WolfRabbitCarrot.WorldFunctions.random_direction())
      |> Map.put(:position, WolfRabbitCarrot.WorldFunctions.random_position())
      |> Map.put(:breed_threshold, WolfRabbitCarrot.wolf_breed_threshold())
      |> Map.put(:max_life, WolfRabbitCarrot.wolf_max_life())
      |> Map.put(:type, :wolf)
      |> Map.put(:pid, self())
      {:ok, state}
  end

  def handle_call("get_position", _from, state) do
    {:reply, state.position, state}
  end

  def handle_info("tick", state) do
    # IO.puts("Rabbit tick")
    # state
    # # get best direction
    # |> Map.put(:direction, WolfRabbitCarrot.WorldFunctions.get_best_direction(state, :rabbit, :nil))
    # # move
    # |> WolfRabbitCarrot.WorldFunctions.move()
    # # age
    # |> WolfRabbitCarrot.WorldFunctions.age()
    # # eat if possible
    # |> WolfRabbitCarrot.WorldFunctions.eat(:rabbit)
    # # breed if possible
    # # |> WolfRabbitCarrot.WorldFunctions.breed()
    # # die if possible
    # |> WolfRabbitCarrot.WorldFunctions.check_death()
    {:noreply, state}
  end
end
