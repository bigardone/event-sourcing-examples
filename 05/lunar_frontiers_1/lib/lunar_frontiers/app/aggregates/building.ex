defmodule LunarFrontiers.App.Aggregates.Building do
  alias __MODULE__
  alias LunarFrontiers.App.Commands.SpawnBuilding
  alias LunarFrontiers.App.Events.BuildingSpawned

  defstruct [:site_id, :site_type, :location, :player_id]

  # Command handlers __________________________________________________________

  def execute(%Building{} = _building, %SpawnBuilding{
        location: location,
        player_id: player_id,
        site_id: site_id,
        site_type: site_type
      }) do
    {:ok,
     %BuildingSpawned{
       location: location,
       player_id: player_id,
       site_id: site_id,
       site_type: site_type
     }}
  end

  # State mutators _____________________________________________________________

  def apply(%Building{} = _building, %BuildingSpawned{
        location: location,
        player_id: player_id,
        site_id: site_id,
        site_type: site_type
      }) do
    %Building{
      location: location,
      player_id: player_id,
      site_id: site_id,
      site_type: site_type
    }
  end
end
