defmodule NetspectBackend.BenchmarkRunner do
  @moduledoc """
  Basic benchmark helper for inspecting current system state.
  """

  alias NetspectBackend.FlowStore
  alias NetspectBackend.TelemetryMetrics

  def snapshot do
    flows = FlowStore.get_flows()
    metrics = TelemetryMetrics.get_metrics()

    %{
      timestamp: DateTime.utc_now(),
      flow_count: length(flows),
      packets_received: metrics.packets_received,
      ingest_errors: metrics.ingest_errors,
      alerts_generated: metrics.alerts_generated
    }
  end
end
