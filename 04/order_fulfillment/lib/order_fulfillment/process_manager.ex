defmodule OrderFulfillment.ProcessManager do
  use GenServer

  alias __MODULE__.State

  defmodule State do
    defstruct [:id, :status, :items]
  end

  # Public API ________________________________________________________________

  def start_link(%{id: _id} = state) do
    GenServer.start_link(__MODULE__, state)
  end

  # GenServer Callbacks _________________________________________________________

  @impl GenServer
  def init(%{id: id}) do
    {:ok, %State{id: id, status: :created, items: []}}
  end

  @impl GenServer
  def handle_call({:process_event, event}, _from, state) do
    handle_event(state, event)
  end

  # Helpers ______________________________________________________________________

  defp handle_event(state, %{event_type: :order_created, items: order_items}) do
    commands =
      Enum.map(order_items, fn item ->
        %{
          command_type: :reserve_quantity,
          aggregate: :stock_unit,
          quantity: item.quantity,
          sku: item.sku
        }
      end)

    state = %{state | status: :created, items: order_items}

    {:reply, commands, state}
  end

  defp handle_event(state, %{event_type: :payment_approved, order_id: order_id}) do
    commands = [%{command_type: :ship_order, aggregate: :order, order_id: order_id}]

    state = %{state | status: :shipping}

    {:reply, commands, state}
  end

  defp handle_event(state, %{event_type: :payment_declined}) do
    state = %{state | status: :payment_failure}

    {:reply, [], state}
  end

  defp handle_event(state, %{event_type: :order_cancelled}) do
    {:stop, :normal, state}
  end

  defp handle_event(state, %{event_type: :order_shipped}) do
    commands =
      Enum.map(state.items, fn item ->
        %{
          command_type: :remove_quantity,
          aggregate: :stock_unit,
          quantity: item.quantity,
          sku: item.sku
        }
      end)

    {:stop, :normal, commands, state}
  end

  defp handle_event(state, %{event_type: :payment_details_updated}) do
    commands = [%{command_type: :ship_order, aggregate: :order, order_id: state.id}]

    {:reply, commands, state}
  end
end
