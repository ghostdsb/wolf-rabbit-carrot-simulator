defmodule WolfRabbitCarrot.RabbitEntity do
  use GenServer, restart: :temporary

  def start_link(opts) do
    GenServer.start_link(__MODULE__, [opts], name: :"rabbit#{DateTime.utc_now() |> DateTime.to_iso8601()}")
  end

  def get_position(pid) do
    cond do
      Process.alive?(pid) ->
        GenServer.call(pid, "get_position")
      true ->
        :error
    end
  end

  def init([opts]) do
    opts =  opts |> Map.new()
    state =
      WolfRabbitCarrot.AnimalState.__struct__()
      |> Map.put(:direction, WolfRabbitCarrot.WorldFunctions.random_direction())
      |> Map.put(:position, WolfRabbitCarrot.WorldFunctions.set_position(opts.position))
      |> Map.put(:breed_threshold, WolfRabbitCarrot.rabbit_breed_threshold())
      |> Map.put(:max_life, WolfRabbitCarrot.rabbit_max_life())
      |> Map.put(:type, :rabbit)
      |> Map.put(:pid, self())
    {:ok, state}
  end

  def handle_call("get_position", _from, state) do
    {:reply, state.position, state}
  end

  def handle_info("tick", state) do
    # IO.puts("Rabbit tick")
      state
      # get best direction
      |> WolfRabbitCarrot.WorldFunctions.set_best_direction(:carrot, :wolf)
      # move
      |> WolfRabbitCarrot.WorldFunctions.move()
      # age
      |> WolfRabbitCarrot.WorldFunctions.age()
      # eat if possible
      |> WolfRabbitCarrot.WorldFunctions.eat(:carrot)
      # breed if possible
      |> WolfRabbitCarrot.WorldFunctions.breed()
      # die if possible
      |> WolfRabbitCarrot.WorldFunctions.check_death()
  end

  def handle_info("eaten", state) do
    {:stop, :shutdown, state}
  end
end

# ```
# out of bounds
# gen direction of target_coordinate_list|>head
# gen direction of danger_coordinates_list|>head
# ```
