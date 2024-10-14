defmodule LunarFrontiers.App.Aggregates.ConstructionSite do
  alias __MODULE__

  alias Commanded.Aggregate.Multi

  alias LunarFrontiers.App.Events.{
    ConstructionCompleted,
    ConstructionProgressed,
    SiteSpawned
  }

  alias LunarFrontiers.App.Commands.{
    AdvanceConstruction,
    SpawnSite
  }

  defstruct [
    :completed,
    :completed_tick,
    :completed_ticks,
    :created_tick,
    :location,
    :player_id,
    :required_ticks,
    :site_id,
    :site_type
  ]

  # Command handlers __________________________________________________________

  def execute(%ConstructionSite{} = _site, %SpawnSite{
        site_id: site_id,
        site_type: site_type,
        completion_ticks: completion_ticks,
        location: location,
        player_id: player_id,
        tick: tick
      }) do
    {:ok,
     %SiteSpawned{
       site_id: site_id,
       site_type: site_type,
       location: location,
       tick: tick,
       remaining_ticks: completion_ticks,
       player_id: player_id
     }}
  end

  def execute(%ConstructionSite{} = site, %AdvanceConstruction{} = command) do
    site
    |> Multi.new()
    |> Multi.execute(&progress_construction(&1, command.tick, command.advance_ticks))
    |> Multi.execute(&check_completed(&1, command.tick))
  end

  # State mutators _____________________________________________________________

  def apply(%ConstructionSite{} = _site, %SiteSpawned{
        site_id: site_id,
        site_type: site_type,
        location: location,
        tick: tick,
        remaining_ticks: remaining_ticks,
        player_id: player_id
      }) do
    %ConstructionSite{
      completed: false,
      completed_ticks: 0,
      created_tick: tick,
      location: location,
      player_id: player_id,
      required_ticks: remaining_ticks,
      site_id: site_id,
      site_type: site_type
    }
  end

  def apply(%ConstructionSite{completed_ticks: completed_ticks} = site, %ConstructionProgressed{
        progressed_ticks: progressed_ticks
      }) do
    %ConstructionSite{site | completed_ticks: completed_ticks + progressed_ticks}
  end

  def apply(%ConstructionSite{} = site, %ConstructionCompleted{tick: tick} = _event) do
    %ConstructionSite{site | completed: true, completed_tick: tick}
  end

  # Helper functions ___________________________________________________________

  defp progress_construction(site, tick, ticks) do
    {:ok,
     %ConstructionProgressed{
       progressed_ticks: ticks,
       required_ticks: site.required_ticks,
       site_id: site.site_id,
       site_type: site.site_type,
       tick: tick
     }}
  end

  defp check_completed(
         %ConstructionSite{
           completed_ticks: completed_ticks,
           required_ticks: required_ticks
         } = site,
         tick
       )
       when completed_ticks >= required_ticks do
    %ConstructionCompleted{
      location: site.location,
      player_id: site.player_id,
      site_id: site.site_id,
      site_type: site.site_type,
      tick: tick
    }
  end

  defp check_completed(%ConstructionSite{} = _site, _tick), do: []
end
