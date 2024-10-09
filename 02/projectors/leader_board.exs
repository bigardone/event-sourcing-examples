defmodule Projectors.LeaderBoard do
  use GenServer

  require Logger

  # Public API _____________________________________________________________

  def start_link do
    GenServer.start_link(__MODULE__, nil)
  end

  def apply_event(pid, event) do
    GenServer.cast(pid, {:handle_event, event})
  end

  def get_top10(pid) do
    GenServer.call(pid, :get_top10)
  end

  def get_score(pid, player) do
    GenServer.call(pid, {:get_score, player})
  end

  # GenServer callbacks ____________________________________________________

  @impl GenServer
  def init(_state) do
    {:ok, %{scores: %{}, top10: []}}
  end

  @impl GenServer
  def handle_call({:get_score, player}, _from, %{scores: scores} = state) do
    {:reply, Map.get(scores, player, 0), state}
  end

  def handle_call(:get_top10, _from, %{top10: top10} = state) do
    {:reply, top10, state}
  end

  @impl GenServer
  def handle_cast({:handle_event, %{event_type: :zombie_killed, player: player}}, state) do
    new_scores = Map.update(state.scores, player, 1, &(&1 + 1))
    {:noreply, %{state | scores: new_scores, top10: rerank(new_scores)}}
  end

  def handle_cast({:handle_event, %{event_type: :week_completed}}, _state) do
    {:noreply, %{scores: %{}, top10: []}}
  end

  defp rerank(scores) do
    scores
    |> Map.to_list()
    |> Enum.sort(fn {_k1, val1}, {_k2, val2} -> val1 >= val2 end)
    |> Enum.take(10)
  end
end
