defmodule LunarFrontiers.App.Aggregates.Gameloop do
  alias __MODULE__
  alias LunarFrontiers.App.Aggregates.Gameloop
  alias LunarFrontiers.App.Commands.AdvanceGameloop
  alias LunarFrontiers.App.Events.GameloopAdvanced

  defstruct [:game_id, :tick]

  # Command handlers __________________________________________________________

  def execute(%Gameloop{} = _gameloop, %AdvanceGameloop{game_id: game_id, tick: tick}) do
    {:ok,
     %GameloopAdvanced{
       game_id: game_id,
       tick: tick
     }}
  end

  # State mutators _____________________________________________________________

  def apply(%Gameloop{} = _gameloop, %GameloopAdvanced{game_id: game_id, tick: tick}) do
    %Gameloop{game_id: game_id, tick: tick}
  end
end
