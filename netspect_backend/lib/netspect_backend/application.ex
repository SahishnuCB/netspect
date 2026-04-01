defmodule NetspectBackend.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      NetspectBackendWeb.Telemetry,
      NetspectBackend.FlowStore,
      NetspectBackend.TelemetryMetrics,
      NetspectBackend.TimelineStore,
      NetspectBackend.EventSnapshotStore,
      NetspectBackend.ResponseEngine,
      {DNSCluster, query: Application.get_env(:netspect_backend, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: NetspectBackend.PubSub},
      NetspectBackendWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: NetspectBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    NetspectBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
