defmodule FlightTracker.AircraftProjector do
  use GenStage

  alias Cloudevents.Format.V_1_0.Event
  alias FlightTracker.MessageBroadcaster

  require Logger

  @ets_table :aircraft_table

  # Public API ________________________________________________________________________

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok)
  end

  def get_state_by_icao(icao_address) do
    case :ets.lookup(@ets_table, icao_address) do
      [{^icao_address, state}] ->
        state

      _ ->
        %{icao_address: icao_address}
    end
  end

  def get_aircraft_by_callsign(callsign) do
    @ets_table
    |> :ets.select([{{:"$1", :"$2"}, [{:==, {:map_get, :callsign, :"$2"}, callsign}], [:"$2"]}])
    |> List.first()
  end

  # GenStage callbacks _________________________________________________________________

  @impl GenStage
  def init(:ok) do
    :ets.new(@ets_table, [:named_table, :set, :public])

    {:consumer, :ok, subscribe_to: [MessageBroadcaster]}
  end

  @impl GenStage
  def handle_events(events, _from, state) do
    for event <- events do
      Logger.debug("#{__MODULE__} Handling event: #{inspect(event)}")

      handle_event(Cloudevents.from_json!(event))
    end

    {:noreply, [], state}
  end

  # Helpers ____________________________________________________________________________

  defp handle_event(%Event{type: "org.book.flighttracker.aircraft_identified", data: data}) do
    icao_address = data["icao_address"]
    callsign = data["callsign"]

    old_state = get_state_by_icao(icao_address)
    new_state = Map.put(old_state, :callsign, callsign)

    insert(icao_address, new_state)
  end

  defp handle_event(%Event{type: "org.book.flighttracker.velocity_reported", data: data}) do
    icao_address = data["icao_address"]
    old_state = get_state_by_icao(icao_address)

    new_state =
      old_state
      |> Map.put(:heading, data["heading"])
      |> Map.put(:ground_speed, data["ground_speed"])
      |> Map.put(:vertical_rate, data["vertical_rate"])

    insert(icao_address, new_state)
  end

  defp handle_event(%Event{type: "org.book.flighttracker.position_reported", data: data}) do
    icao_address = data["icao_address"]
    old_state = get_state_by_icao(icao_address)

    new_state =
      old_state
      |> Map.put(:altitude, data["altitude"])
      |> Map.put(:longitude, data["longitude"])
      |> Map.put(:latitude, data["latitude"])

    insert(icao_address, new_state)
  end

  defp handle_event(_event), do: :ignore

  defp insert(icao_address, data) do
    :ets.insert(@ets_table, {icao_address, data})
  end
end
