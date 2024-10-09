defmodule EventSourcedCalculator.V1 do
  def handle_command(%{value: value}, %{cmd: :add, value: v}) do
    %{value: value + v}
  end

  def handle_command(%{value: value}, %{cmd: :sub, value: v}) do
    %{value: value - v}
  end

  def handle_command(%{value: value}, %{cmd: :mul, value: v}) do
    %{value: value * v}
  end

  def handle_command(%{value: value}, %{cmd: :div, value: v}) do
    %{value: value / v}
  end
end
