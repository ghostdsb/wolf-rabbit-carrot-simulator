defmodule WolfRabbitCarrot.CarrotEntity do
  use GenServer, restart: :temporary

  @doc """
  defmodule CarrotState do
    defstruct(
      position: %{x: 0, y: 0},
      age: 0,
      max_life: 100
    )
  end
  """

  def start_link(_args) do
    GenServer.start_link(__MODULE__, [], name: :"carrot#{DateTime.utc_now() |> DateTime.to_iso8601()}")
  end

  def get_position(pid) do
    cond do
      Process.alive?(pid) ->
        GenServer.call(pid, "get_position")
      true ->
        :error
    end
  end

  def init([]) do
    state =
      WolfRabbitCarrot.CarrotState.__struct__()
      |> Map.put(:position, WolfRabbitCarrot.WorldFunctions.random_position())
      {:ok, state}
  end

  def handle_call("get_position", _from, state) do
    {:reply, state.position, state}
  end

  def handle_info("tick", state) do
    state
    |> WolfRabbitCarrot.WorldFunctions.age()
    |> WolfRabbitCarrot.WorldFunctions.check_death()
  end

  def handle_info("eaten", state) do
    {:stop, :shutdown, state}
  end

end
