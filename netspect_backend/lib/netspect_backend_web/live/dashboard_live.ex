defmodule NetspectBackendWeb.DashboardLive do
  use NetspectBackendWeb, :live_view

  alias NetspectBackend.FlowStore
  alias NetspectBackend.AlertEngine

  @refresh_interval 300

  @impl true
  def mount(_params, _session, socket) do
    flows = FlowStore.get_flows()
    alerts = Enum.flat_map(flows, &AlertEngine.analyze_flow/1)
    suspicious_nodes = AlertEngine.suspicious_nodes(flows)

    if connected?(socket) do
      :timer.send_interval(@refresh_interval, self(), :refresh_flows)
    end

    {:ok,
      socket
      |> assign(:page_title, "NetSpect Dashboard")
      |> assign(:flows, flows)
      |> assign(:alerts, alerts)
      |> assign(:suspicious_nodes, suspicious_nodes)}
  end

  @impl true
  def handle_info(:refresh_flows, socket) do
    flows =
      FlowStore.get_flows()
      |> Enum.take(30) # Limit to latest 30 flows for performance
    alerts = Enum.flat_map(flows, &AlertEngine.analyze_flow/1)
    suspicious_nodes = AlertEngine.suspicious_nodes(flows)

    socket =
      socket
      |> assign(:flows, flows)
      |> assign(:alerts, alerts)
      |> assign(:suspicious_nodes, suspicious_nodes)
      |> push_event("flows_updated", %{
        flows: flows,
        suspicious_nodes: suspicious_nodes
      })

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
        Real-time visualization of network flows and suspicious nodes
      </p>

      <div style="display: flex; gap: 20px; margin-bottom: 20px;">
        <div style="padding: 12px 16px; border: 1px solid #ccc; border-radius: 10px;">
          <strong>Total flows:</strong> <%= length(@flows) %>
        </div>

        <div style="padding: 12px 16px; border: 1px solid #ccc; border-radius: 10px;">
          <strong>Total alerts:</strong> <%= length(@alerts) %>
        </div>

        <div style="padding: 12px 16px; border: 1px solid #ccc; border-radius: 10px;">
          <strong>Suspicious nodes:</strong> <%= length(@suspicious_nodes) %>
        </div>
      </div>

      <div
        id="graph"
        phx-hook="GraphHook"
        phx-update="ignore"
        style="width: 100%; height: 600px; border: 1px solid #ccc; border-radius: 10px;">
      </div>

      <div style="margin-top: 30px;">
        <h2 style="font-size: 22px; font-weight: bold; margin-bottom: 10px;">
          Alerts
        </h2>

        <%= if @alerts == [] do %>
          <p style="color: gray;">No alerts detected yet.</p>
        <% else %>
          <div style="display: flex; flex-direction: column; gap: 10px;">
            <%= for alert <- @alerts do %>
              <div style="padding: 12px; border: 1px solid #e5a50a; background: #fff8e1; border-radius: 8px;">
                <strong>[<%= alert.severity %>]</strong> <%= alert.message %><br/>
                <span><%= alert.src_ip %> → <%= alert.dst_ip %></span>
                <%= if Map.has_key?(alert, :dst_port) do %>
                  <span> | Port: <%= alert.dst_port %></span>
                <% end %>
                <%= if Map.has_key?(alert, :packet_count) do %>
                  <span> | Packets: <%= alert.packet_count %></span>
                <% end %>
                <%= if Map.has_key?(alert, :total_bytes) do %>
                  <span> | Bytes: <%= alert.total_bytes %></span>
                <% end %>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
