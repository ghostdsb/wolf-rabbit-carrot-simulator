defmodule WolfRabbitCarrot do
  @moduledoc """
  WolfRabbitCarrot keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @rabbit_breed_threshold 10
  @wolf_breed_threshold 5
  @rabbit_max_life 1000
  @wolf_max_life 10

  defmodule WorldState do
    defstruct(
      board_size: 20,
      carrot_count: 400,
      new_carrot_count: 5,
      rabbit_count: 1,
      wolf_count: 1
    )
  end

  defmodule AnimalState do
    defstruct(
      position: %{x: 0, y: 0},
      age: 0,
      health: 0,
      max_life: nil,
      direction: nil,
      breed_threshold: nil,
      target_coordinates: [],
      danger_coordinates: []
    )
  end

  defmodule CarrotState do
    defstruct(
      position: %{x: 0, y: 0},
      age: 0,
      max_life: 1000
    )
  end

  @spec rabbit_breed_threshold :: number()
  def rabbit_breed_threshold, do: @rabbit_breed_threshold

  @spec wolf_breed_threshold :: number()
  def wolf_breed_threshold, do: @wolf_breed_threshold

  @spec rabbit_max_life :: number()
  def rabbit_max_life, do: @rabbit_max_life

  @spec wolf_max_life :: number
  def wolf_max_life, do: @wolf_max_life


end
