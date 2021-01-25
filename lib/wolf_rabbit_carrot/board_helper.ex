defmodule WolfRabbitCarrot.BoardHelper do

  def make_board() do
    empty_board()
    |> place_carrots()
    |> place_rabbits()
    |> place_wolves()
    |> Enum.chunk_every(WolfRabbitCarrot.WorldState.__struct__().board_size)

  end

  def population do
    carrot_count = WolfRabbitCarrot.WorldFunctions.get_position(:carrot) |> Enum.count()
    rabbit_count = WolfRabbitCarrot.WorldFunctions.get_position(:rabbit) |> Enum.count()
    wolf_count = WolfRabbitCarrot.WorldFunctions.get_position(:wolf) |> Enum.count()
    %{carrot_pop: carrot_count, rabbit_pop: rabbit_count, wolf_pop: wolf_count}
  end

  defp empty_board() do
    1..(WolfRabbitCarrot.WorldState.__struct__().board_size*WolfRabbitCarrot.WorldState.__struct__().board_size)
    |> Enum.map(fn _x -> "⬜" end)
  end

  def place_carrots(board) do
    WolfRabbitCarrot.WorldFunctions.get_position(:carrot)
    |> Enum.map(fn coor -> convert2d1d(coor) end)
    |> Enum.reduce(board, fn pos,acc -> update_board(acc, pos, "🌰") end) #⭕
  end

  def place_rabbits(board) do
    WolfRabbitCarrot.WorldFunctions.get_position(:rabbit)
    |> Enum.map(fn coor -> convert2d1d(coor) end)
    |> Enum.reduce(board, fn pos,acc -> update_board(acc, pos, "🐑") end) #🔵
  end

  def place_wolves(board) do
    WolfRabbitCarrot.WorldFunctions.get_position(:wolf)
    |> Enum.map(fn coor -> convert2d1d(coor) end)
    |> Enum.reduce(board, fn pos,acc -> update_board(acc, pos, "🐺") end) #🔴
  end

  def convert2d1d(%{x: x, y: y}) do
    WolfRabbitCarrot.WorldState.__struct__().board_size*(y-1) + (x-1)
  end

  def update_board(board, pos, value) do
    board |> List.replace_at(pos, value)
  end

end
