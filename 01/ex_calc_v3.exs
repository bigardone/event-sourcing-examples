defmodule EventSourcedCalculator.V3 do
  @max_state_value 10_000
  @min_state_value 0

  def handle_command(%{value: value}, %{cmd: :add, value: v}) do
    {:ok, %{event_type: :value_added, value: min(@max_state_value - value, v)}}
  end

  def handle_command(%{value: value}, %{cmd: :sub, value: v}) do
    {:ok, %{event_type: :value_subtracted, value: max(@min_state_value, value - v)}}
  end

  def handle_command(%{value: value}, %{cmd: :mul, value: v})
      when value * v > @max_state_value do
    {:error, :mul_failed}
  end

  def handle_command(%{value: _value}, %{cmd: :mul, value: v}) do
    {:ok, %{event_type: :value_multiplied, value: v}}
  end

  def handle_command(%{value: _value}, %{cmd: :div, value: 0}) do
    {:error, :div_failed}
  end

  def handle_command(%{value: _value}, %{cmd: :div, value: v}) do
    {:ok, %{event_type: :value_divided, value: v}}
  end

  def handle_event(%{value: value}, %{event_type: :value_added, value: v}) do
    %{value: value + v}
  end

  def handle_event(%{value: value}, %{event_type: :value_subtracted, value: v}) do
    %{value: value - v}
  end

  def handle_event(%{value: value}, %{event_type: :value_multiplied, value: v}) do
    %{value: value * v}
  end

  def handle_event(%{value: value}, %{event_type: :value_divided, value: v}) do
    %{value: value / v}
  end

  def handle_event(state, _event) do
    state
  end
end
