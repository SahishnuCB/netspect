defmodule NetspectBackend.TelemetryMetrics do
  use GenServer

  @moduledoc """
  Simple in-memory telemetry counters for the MVP.
  """

  # ---------- Client API ----------

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{
      packets_received: 0,
      ingest_errors: 0,
      alerts_generated: 0
    }, name: __MODULE__)
  end

  def increment_packets do
    GenServer.cast(__MODULE__, :increment_packets)
  end

  def increment_ingest_errors do
    GenServer.cast(__MODULE__, :increment_ingest_errors)
  end

  def increment_alerts(count \\ 1) do
    GenServer.cast(__MODULE__, {:increment_alerts, count})
  end

  def get_metrics do
    GenServer.call(__MODULE__, :get_metrics)
  end

  # ---------- Server ----------

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_cast(:increment_packets, state) do
    {:noreply, Map.update!(state, :packets_received, &(&1 + 1))}
  end

  @impl true
  def handle_cast(:increment_ingest_errors, state) do
    {:noreply, Map.update!(state, :ingest_errors, &(&1 + 1))}
  end

  @impl true
  def handle_cast({:increment_alerts, count}, state) do
    {:noreply, Map.update!(state, :alerts_generated, &(&1 + count))}
  end

  @impl true
  def handle_call(:get_metrics, _from, state) do
    {:reply, state, state}
  end
end
