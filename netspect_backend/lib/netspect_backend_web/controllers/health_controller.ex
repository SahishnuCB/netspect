defmodule NetspectBackendWeb.HealthController do
  use NetspectBackendWeb, :controller

  alias NetspectBackend.FlowStore
  alias NetspectBackend.AlertEngine
  alias NetspectBackend.GraphStore
  alias NetspectBackend.TelemetryMetrics
  alias NetspectBackend.TimelineStore
  alias NetspectBackend.EventSnapshotStore
  alias NetspectBackend.BenchmarkRunner
  alias NetspectBackend.ResponseEngine

  def index(conn, _params) do
    flows = FlowStore.get_flows()
    alerts = flows |> Enum.flat_map(&AlertEngine.analyze_flow/1)
    graph = GraphStore.build_graph(flows)
    metrics = TelemetryMetrics.get_metrics()
    timeline = TimelineStore.get_events()
    snapshots = EventSnapshotStore.get_snapshots()
    benchmark = BenchmarkRunner.snapshot()
    blocked_ips = ResponseEngine.get_blocked_ips()

    json(conn, %{
      status: "ok",
      flow_count: length(flows),
      alert_count: length(alerts),
      flows: flows,
      alerts: alerts,
      graph: graph,
      metrics: metrics,
      timeline: timeline,
      snapshots: snapshots,
      benchmark: benchmark,
      blocked_ips: blocked_ips
    })
  end
end
