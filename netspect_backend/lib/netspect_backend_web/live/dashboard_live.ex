defmodule NetspectBackendWeb.DashboardLive do
  use NetspectBackendWeb, :live_view

  alias NetspectBackend.FlowStore

  @refresh_interval 1000

  @impl true
  def mount(_params, _session, socket) do
    flows = FlowStore.get_flows()

    if connected?(socket) do
      :timer.send_interval(@refresh_interval, self(), :refresh_flows)
    end

    {:ok,
      socket
      |> assign(:page_title, "NetSpect Dashboard")
      |> assign(:flows, flows)}
  end

  @impl truegit add netspect_backend/lib/netspect_backend_web/live/dashboard_live.ex

  def handle_info(:refresh_flows, socket) do
    flows = FlowStore.get_flows()

    socket =
      socket
      |> assign(:flows, flows)
      |> push_event("flows_updated", %{flows: flows})

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div style="padding: 30px;">
      <h1 style="font-size: 28px; font-weight: bold; margin-bottom: 20px;">
        NetSpect Live Network Graph
      </h1>

      <p style="margin-bottom: 20px; color: gray;">
        Real-time visualization of network flows (source → destination)
      </p>

      <div
        id="graph"
        phx-hook="GraphHook"
        phx-update="ignore"
        style="width: 100%; height: 600px; border: 1px solid #ccc; border-radius: 10px;">
      </div>

      <div style="margin-top: 20px;">
        <strong>Total flows:</strong> <%= length(@flows) %>
      </div>
    </div>
    """
  end
end
