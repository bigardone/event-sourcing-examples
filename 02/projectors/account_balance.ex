defmodule Projectors.AccountBalance do
  use GenServer

  require Logger

  # Public API _____________________________________________________________

  def start_link(account_number) do
    GenServer.start_link(__MODULE__, account_number, name: via(account_number))
  end

  def apply_event(%{account_number: account_number} = event) when is_binary(account_number) do
    case Registry.lookup(Registry.AccountProjectors, account_number) do
      [{pid, _}] ->
        apply_event(pid, event)

      _other ->
        Logger.debug("Attempt to apply event to non-existing account, starting projector")
        {:ok, pid} = start_link(account_number)
        apply_event(pid, event)
    end
  end

  def apply_event(pid, event) when is_pid(pid) do
    GenServer.cast(pid, {:handle_event, event})
  end

  def lookup_balance(account_number) when is_binary(account_number) do
    case Registry.lookup(Registry.AccountProjectors, account_number) do
      [{pid, _}] ->
        {:ok, GenServer.call(pid, :get_balance)}

      _other ->
        {:error, :unknown_account}
    end
  end

  # GenServer callbacks ____________________________________________________

  @impl GenServer
  def init(account_number) do
    {:ok, %{balance: 0, account_number: account_number}}
  end

  @impl GenServer
  def handle_cast({:handle_event, event}, state) do
    {:noreply, handle_event(state, event)}
  end

  @impl GenServer
  def handle_call(:get_balance, _from, state) do
    {:reply, state.balance, state}
  end

  # Helpers ________________________________________________________________

  defp via(account_number) do
    {:via, Registry, {Registry.AccountProjectors, account_number}}
  end

  defp handle_event(%{balance: balance} = state, %{event_type: :amount_withdrawn, value: value}) do
    %{state | balance: balance - value}
  end

  defp handle_event(%{balance: balance} = state, %{event_type: :amount_deposited, value: value}) do
    %{state | balance: balance + value}
  end

  defp handle_event(%{balance: balance} = state, %{event_type: :fee_applied, value: value}) do
    %{state | balance: balance - value}
  end
end
