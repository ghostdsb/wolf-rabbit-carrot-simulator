defmodule WolfRabbitCarrot.WorldFunctions do

  def plant_carrots(carrot_count) do
    1..carrot_count
    |> Enum.each(fn _index ->
      DynamicSupervisor.start_child(WolfRabbitCarrot.CarrotSupervisor, {WolfRabbitCarrot.CarrotEntity, []})
    end)
  end

  def breed_rabbits(rabbit_count, opts \\ [position: %{}]) do
    opts |> IO.inspect()
    1..rabbit_count
    |> Enum.each(fn _index ->
      DynamicSupervisor.start_child(WolfRabbitCarrot.RabbitSupervisor, {WolfRabbitCarrot.RabbitEntity, opts})
    end)
  end

  def breed_wolves(wolf_count) do
    1..wolf_count
    |> Enum.each(fn _index ->
      DynamicSupervisor.start_child(WolfRabbitCarrot.WolfSupervisor, {WolfRabbitCarrot.WolfEntity, []})
    end)
  end

  def get_carrots do
    Supervisor.which_children(WolfRabbitCarrot.CarrotSupervisor)
    |> Enum.map(fn {_id, pid, _type, _module} -> pid end)
  end

  def get_rabbits do
    Supervisor.which_children(WolfRabbitCarrot.RabbitSupervisor)
    |> Enum.map(fn {_id, pid, _type, _module} -> pid end)
  end

  def get_wolves do
    Supervisor.which_children(WolfRabbitCarrot.WolfSupervisor)
    |> Enum.map(fn {_id, pid, _type, _module} -> pid end)
  end

  def get_position(:carrot) do
    get_carrots()
    |> Enum.map(fn carrot_pid -> WolfRabbitCarrot.CarrotEntity.get_position(carrot_pid) end)
  end

  def get_position(:rabbit) do
    get_rabbits()
    |> Enum.map(fn rabbit_pid -> WolfRabbitCarrot.RabbitEntity.get_position(rabbit_pid) end)
  end

  def get_position(:wolf) do
    get_wolves()
    |> Enum.map(fn wolf_pid -> WolfRabbitCarrot.WolfEntity.get_position(wolf_pid) end)
  end

  def random_position do
    %{x: :rand.uniform(WolfRabbitCarrot.WorldState.__struct__().board_size), y: :rand.uniform(WolfRabbitCarrot.WorldState.__struct__().board_size)}
  end

  def set_position(position) do
    cond do
      Enum.empty?(position) ->
        random_position()
      true ->
        position
    end
  end

  def random_direction do
    ~w(n ne e se s sw w nw) |> Enum.random()
  end


  def age(%{age: age} = state) do
    %{state | age: age + 1}
  end

  def move(state) do
    %{x: x, y: y} = state.position
    case state.direction do
      "n"  -> %{state | position: %{x: x, y: y-1}}
      "ne" -> %{state | position: %{x: x+1, y: y-1}}
      "e"  -> %{state | position: %{x: x+1, y: y}}
      "se" -> %{state | position: %{x: x+1, y: y+1}}
      "s"  -> %{state | position: %{x: x, y: y+1}}
      "sw" -> %{state | position: %{x: x-1, y: y+1}}
      "w"  -> %{state | position: %{x: x-1, y: y}}
      "nw" -> %{state | position: %{x: x-1, y: y-1}}
      "c"  -> %{state | position: %{x: x, y: y}}
    end
  end

  def eat(state, :carrot) do
    %{x: x, y: y} = state.position

    get_carrots()
    |> Enum.filter(fn carrot_pid -> Process.alive?(carrot_pid) end)
    |> Enum.map(fn carrot_pid -> {carrot_pid, WolfRabbitCarrot.CarrotEntity.get_position(carrot_pid)} end)
    |> Enum.filter(fn val -> val !== :error end)
    |> Enum.filter( fn {_carrot_pid, %{x: carrot_x, y: carrot_y}} -> x == carrot_x && y == carrot_y end)
    |> try_to_eat(state)

  end

  def eat(state, :rabbit) do
    %{x: x, y: y} = state.position

    get_rabbits()
    |> Enum.map(fn rabbit_pid -> {rabbit_pid, WolfRabbitCarrot.RabbitEntity.get_position(rabbit_pid)} end)
    |> Enum.filter( fn {_rabbit_pid, %{x: rabbit_x, y: rabbit_y}} -> x == rabbit_x && y == rabbit_y end)
    |> try_to_eat(state)

  end

  defp try_to_eat([], state), do: state
  defp try_to_eat([{food_pid, %{x: _food_x, y: _food_y}}| _rest_food], %{health: health} = state) do
    send(food_pid, "eaten")
    %{state | health: health+1}
  end

  def breed(state) do
    %{health: health, breed_threshold: breed_threshold} = state
    cond do
      health >= breed_threshold ->
        breed_rabbits(1, [position: state.position])
        %{state | health: 0}
      true ->
        state
    end
  end

  def check_death(%{age: age, max_life: max_life} = state) do
    cond do
      age > max_life ->
        IO.puts("rabbit dead")
        {:stop, :shutdown, state}
      true ->
        {:noreply, state}
    end
  end

  def set_best_direction(state, food_type, danger_type) do
    %{
      position: %{x: x, y: y},
      direction: direction,
      target_coordinates: target_coordinates_list,
      danger_coordinates: danger_coordinates_list
    } = state

    direction =
      state
      |> possible_positions()
      |> Enum.filter(fn position -> not out_of_bounds?(position) end)
      |> Enum.filter(fn position -> not danger_here?(position, danger_type) end)

      |> Enum.map(fn position -> {position, set_position_score(position, food_type, danger_type)} end)
      |> Enum.sort(fn {_a1, s1}, {_a2, s2} -> s1>s2 end)
      |> no_food_check()
      |> Enum.map(fn {position, _score} -> position end)

      |> List.first()
      |> get_general_direction(%{x: x, y: y})
    %{state | direction: direction}
  end

  defp no_food_check(position_score_tuple_list) do
    cond do
      position_score_tuple_list
      |> Enum.filter(fn {_position, score} -> score > 0 end)
      |> Enum.all?(fn {_position, score} -> score == 10 end) ->
        position_score_tuple_list |> Enum.shuffle()
      true -> position_score_tuple_list
    end
  end

  def get_general_direction(nil, _self_pos), do: "c"

  def get_general_direction(%{x: target_x, y: target_y} = _target_pos, %{x: x, y: y} = _self_pos) do
    cond do
      target_x > x && target_y == y -> "e"
      target_x > x && target_y >  y -> "se"
      target_x > x && target_y <  y -> "ne"
      target_x == x && target_y < y -> "n"
      target_x < x && target_y <  y -> "nw"
      target_x < x && target_y == y -> "w"
      target_x < x && target_y > y  -> "sw"
      target_x == x && target_y > y -> "s"
      target_x == x && target_y == y -> "c"
    end
  end

  def possible_positions(state) do
    %{x: x, y: y} = state.position
    [
      %{x: x+1, y: y-1},
      %{x: x+1, y: y},
      %{x: x+1, y: y+1},
      %{x: x, y: y+1},
      %{x: x, y: y-1},
      %{x: x-1, y: y+1},
      %{x: x-1, y: y},
      %{x: x-1, y: y-1},
    ]
  end

  def out_of_bounds?(%{x: x, y: y} = _position) do
    x > WolfRabbitCarrot.WorldState.__struct__().board_size || y > WolfRabbitCarrot.WorldState.__struct__().board_size || x < 1 || y < 1
  end

  def food_here?(%{x: x, y: y} = _position, :carrot) do

    get_carrots()
    |> Enum.filter(fn carrot_pid -> Process.alive?(carrot_pid) end)
    |> Enum.map(fn carrot_pid -> WolfRabbitCarrot.CarrotEntity.get_position(carrot_pid) end)
    |> Enum.any?(fn %{x: carrot_x, y: carrot_y} = _carrot_position -> carrot_x == x && carrot_y == y end)
  end

  def food_here?(%{x: x, y: y} = _position, :rabbit) do
    get_position(:rabbit)
    |> Enum.any?(fn %{x: rabbit_x, y: rabbit_y} = _rabbit_position -> rabbit_x == x && rabbit_y == y end)
  end

  def food_here?(_position, _food_type), do: false

  def danger_here?(%{x: x, y: y} = _position, :wolf) do
    get_position(:wolf)
    |> Enum.any?(fn %{x: wolf_x, y: wolf_y} -> wolf_x == x && wolf_y == y end)
  end

  def danger_here?(_position, _danger_type), do: false

  def set_position_score(position, food_type, danger_type) do
    cond do
      food_here?(position, food_type) -> 1000
      danger_here?(position, danger_type) -> -1000
      true -> 10
    end
  end

end
