defmodule FlightTracker.MessageBroadcaster do
  use GenStage

  require Logger

  # Public API _______________________________________________________________

  def start_link(_opts) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc """
  Injects a raw meesage that is not in cloud event format
  """
  def broadcast_message(message) do
    GenStage.call(__MODULE__, {:noify, message})
  end

  @doc """
  Injects a cloud event to be published to the stage pipeline
  """
  def broadcast_event(event) do
    GenStage.call(__MODULE__, {:notify_event, event})
  end

  # GenServer Callbacks __________________________________________________________

  @impl GenStage
  def init(:ok) do
    {:producer, :ok, dispatcher: GenStage.BroadcastDispatcher}
  end

  @impl GenStage
  def handle_call({:noify, message}, _from, state) do
    {:reply, :ok, [to_event(message)], state}
  end

  def handle_call({:notify_event, event}, _from, state) do
    {:reply, :ok, [event], state}
  end

  @impl GenStage
  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end

  # Helpers ________________________________________________________________________

  defp to_event(%{
         type: :aircraft_identified,
         message:
           %{
             icao_address: _icao_address,
             callsign: _callsign,
             emitter_category: _emitter_category
           } = message
       }) do
    new_cloud_event("aircraft_identified", message)
  end

  defp to_event(%{
         type: :squawk_received,
         message: %{squawk: _squawk, icao_address: _icao_address} = message
       }) do
    new_cloud_event("squawk_received", message)
  end

  defp to_event(%{
         type: :position_reported,
         message: %{
           icao_address: icao_address,
           position: %{
             altitude: altitude,
             longitude: longitude,
             latitude: latitude
           }
         }
       }) do
    new_cloud_event("position_reported", %{
      icao_address: icao_address,
      altitude: altitude,
      longitude: longitude,
      latitude: latitude
    })
  end

  defp to_event(%{
         type: :velocity_reported,
         message:
           %{
             heading: _heading,
             ground_speed: _ground_speed,
             vertical_rate: _vertical_rate,
             vertical_rate_source: vertical_rate_source
           } = message
       }) do
    source =
      case vertical_rate_source do
        :barometric_pressure ->
          "barometric"

        :geometric ->
          "geometric"
      end

    new_cloud_event("velocity_reported", %{message | vertical_rate_source: source})
  end

  defp to_event(message) do
    Logger.error("Unknown message: #{inspect(message)}")
  end

  defp new_cloud_event(type, message) do
    %{
      "specversion" => "1.0",
      "type" => "org.book.flighttracker.#{String.downcase(type)}",
      "source" => "radio_aggregator",
      "id" => UUID.uuid4(),
      "datacontenttype" => "application/json",
      "time" => DateTime.utc_now() |> DateTime.to_iso8601(),
      "data" => message
    }
  end
end
