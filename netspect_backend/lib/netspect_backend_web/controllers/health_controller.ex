defmodule NetspectBackendWeb.HealthController do
  use NetspectBackendWeb, :controller

  alias NetspectBackend.FlowStore
  alias NetspectBackend.AlertEngine

  def index(conn, _params) do
    flows = FlowStore.get_flows()

    alerts =
      flows
      |> Enum.flat_map(&AlertEngine.analyze_flow/1)

    json(conn, %{
      status: "ok",
      flow_count: length(flows),
      alert_count: length(alerts),
      flows: flows,
      alerts: alerts
    })
  end
end
