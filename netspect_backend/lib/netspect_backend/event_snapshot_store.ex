defmodule NetspectBackend.EventSnapshotStore do
  use GenServer

  @moduledoc """
  Stores snapshots of alert-triggering events for replay/investigation.
  """

  @max_snapshots 50

  # ---------- Client API ----------

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def record_snapshot(snapshot) do
    GenServer.cast(__MODULE__, {:record_snapshot, snapshot})
  end

  def get_snapshots do
    GenServer.call(__MODULE__, :get_snapshots)
  end

  # ---------- Server ----------

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_cast({:record_snapshot, snapshot}, state) do
    new_snapshot =
      Map.put(snapshot, :timestamp, DateTime.utc_now())

    new_state =
      [new_snapshot | state]
      |> Enum.take(@max_snapshots)

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_snapshots, _from, state) do
    {:reply, Enum.reverse(state), state}
  end
end
