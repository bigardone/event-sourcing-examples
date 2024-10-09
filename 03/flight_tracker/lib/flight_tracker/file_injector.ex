defmodule FlightTracker.FileInjector do
  use GenServer

  alias FlightTracker.MessageBroadcaster

  # Public API ____________________________________________________________________________

  def start_link(file) do
    GenServer.start_link(__MODULE__, file, name: __MODULE__)
  end

  # GenServer callbacks _________________________________________________________________________

  @impl GenServer
  def init(file) do
    Process.send_after(self(), :read_file, 2_000)

    {:ok, file}
  end

  @impl GenServer
  def handle_info(:read_file, file) do
    File.stream!(file)
    |> Enum.map(&String.trim/1)
    |> Enum.each(fn event -> MessageBroadcaster.broadcast_event(event) end)

    {:noreply, file}
  end
end
