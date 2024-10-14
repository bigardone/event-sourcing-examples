defmodule LunarFrontiers.App.ProcessManagers.Construction do
  use Commanded.ProcessManagers.ProcessManager,
    application: LunarFrontiers.App.Application,
    name: __MODULE__

  alias __MODULE__
  alias Commanded.ProcessManagers.ProcessManager

  alias LunarFrontiers.App.Events.{
    BuildingSpawned,
    ConstructionCompleted,
    ConstructionProgressed,
    SiteSpawned
  }

  alias LunarFrontiers.App.Commands.SpawnBuilding

  require Logger

  @derive Jason.Encoder
  defstruct [
    :site_id,
    :status,
    :tick_started,
    :ticks_completed,
    :ticks_required
  ]

  # Event routing _________________________________________________________________

  @impl ProcessManager
  def interested?(%SiteSpawned{site_id: site_id}) do
    {:start, site_id}
  end

  def interested?(%ConstructionProgressed{site_id: site_id}) do
    {:continue, site_id}
  end

  def interested?(%ConstructionCompleted{site_id: site_id}) do
    {:continue, site_id}
  end

  def interested?(%BuildingSpawned{site_id: site_id}) do
    {:stop, site_id}
  end

  def interested?(_other_event), do: false

  # Command dispatchers __________________________________________________________

  @impl ProcessManager
  def handle(%Construction{}, %ConstructionCompleted{
        location: location,
        player_id: player_id,
        site_id: site_id,
        site_type: site_type,
        tick: tick
      }) do
    %SpawnBuilding{
      location: location,
      player_id: player_id,
      site_id: site_id,
      site_type: site_type,
      tick: tick
    }
  end

  # Error handling ________________________________________________________________

  @impl ProcessManager
  def error(error, _failure_source, _failure_context) do
    Logger.error(fn -> "#{__MODULE__} encountered an error: #{inspect(error)}" end)

    :skip
  end
end
