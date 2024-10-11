defmodule Batch.ProcessManager do
  use GenServer

  # Public API ______________________________________________________________

  def start_link(%{id: _id} = state) do
    GenServer.start_link(__MODULE__, state)
  end

  # GenServer callbacks ______________________________________________________

  @impl GenServer
  def init(%{id: id}) do
    {:ok, %{id: id, files: %{}, status: :idle}}
  end

  @impl GenServer
  def handle_call({:process_event, event}, _from, state) do
    handle_event(state, event)
  end

  # Helper functions ________________________________________________________

  defp handle_event(state, %{event_type: :batch_created, files: files}) do
    new_files =
      files
      |> Enum.map(fn file -> {file, :pending} end)
      |> Map.new()

    new_state = %{state | files: new_files, status: :created}

    reply = Enum.map(files, fn file -> %{command_type: :process_file, file: file} end)

    {:reply, reply, new_state}
  end

  defp handle_event(state, %{
         event_type: :file_processed,
         file: %{id: file_id, status: file_status}
       }) do
    files = Map.put(state.files, file_id, file_status)

    new_state = %{state | files: files, status: determine_status(files)}

    # To add functionality we could send retry commands for files that failed

    {:reply, [], new_state}
  end

  defp determine_status(files) do
    cond do
      Enum.all?(files, fn {_id, status} -> status == :success end) ->
        :success

      Enum.any?(files, fn {_id, status} -> status == :error end) ->
        :error

      true ->
        :pending
    end
  end
end
