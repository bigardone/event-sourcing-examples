defmodule FlightTracker.FlightNotifier do
  use GenStage

  alias Cloudevents.Format.V_1_0.Event

  alias FlightTracker.{
    AircraftProjector,
    MessageBroadcaster
  }

  require Logger

  # Public API ____________________________________________________________________________

  def start_link(callsign) do
    GenStage.start_link(__MODULE__, callsign)
  end

  # GenStage callbacks _________________________________________________________________________

  @impl GenStage
  def init(callsign) do
    {:consumer, callsign, subscribe_to: [MessageBroadcaster]}
  end

  @impl GenStage
  def handle_events(events, _from, state) do
    for event <- events do
      handle_event(Cloudevents.from_json!(event), state)
    end

    {:noreply, [], state}
  end

  # Helper functions _________________________________________________________________________

  defp handle_event(
         %Event{type: "org.book.flighttracker.position_reported", data: data} = event,
         callsign
       ) do
    Logger.debug("#{__MODULE__} Handling event: #{inspect(event)}")

    aircraft = AircraftProjector.get_state_by_icao(data["icao_addres"])

    aircraft_callsign =
      aircraft
      |> Map.get(:callsign, "")
      |> String.trim()

    if aircraft_callsign == callsign do
      Logger.info(
        "Flight #{aircraft_callsign}'s poisition #{data["latitude"]}, #{data["longitude"]}"
      )
    end
  end

  defp handle_event(event, _state) do
    Logger.debug("#{__MODULE__} Ignoring event: #{inspect(event)}")
  end
end
