defmodule NetspectBackendWeb.DashboardLive do
  use NetspectBackendWeb, :live_view

  alias NetspectBackend.FlowStore
  alias NetspectBackend.AlertEngine
  alias NetspectBackend.ResponseEngine

  @refresh_interval 1000
  @max_flows 25

  @impl true
  def mount(_params, _session, socket) do
    flows = latest_flows()
    alerts = Enum.flat_map(flows, &AlertEngine.analyze_flow/1)
    suspicious_nodes = AlertEngine.suspicious_nodes(flows)
    local_nodes = detect_local_nodes(flows)
    blocked_ips = ResponseEngine.get_blocked_ips()

    if connected?(socket) do
      :timer.send_interval(@refresh_interval, self(), :refresh_flows)
    end

    {:ok,
     socket
     |> assign(:page_title, "NetSpect Dashboard")
     |> assign(:flows, flows)
     |> assign(:alerts, alerts)
     |> assign(:suspicious_nodes, suspicious_nodes)
     |> assign(:local_nodes, local_nodes)
     |> assign(:blocked_ips, blocked_ips)
     |> assign(:selected_node, nil)
     |> assign(:selected_flows, [])}
  end

  @impl true
  def handle_info(:refresh_flows, socket) do
    flows = latest_flows()
    alerts = Enum.flat_map(flows, &AlertEngine.analyze_flow/1)
    suspicious_nodes = AlertEngine.suspicious_nodes(flows)
    local_nodes = detect_local_nodes(flows)
    blocked_ips = ResponseEngine.get_blocked_ips()

    selected_flows =
      case socket.assigns.selected_node do
        nil -> []
        ip -> Enum.filter(flows, fn flow -> flow.src_ip == ip or flow.dst_ip == ip end)
      end

    socket =
      socket
      |> assign(:flows, flows)
      |> assign(:alerts, alerts)
      |> assign(:suspicious_nodes, suspicious_nodes)
      |> assign(:local_nodes, local_nodes)
      |> assign(:blocked_ips, blocked_ips)
      |> assign(:selected_flows, selected_flows)
      |> push_event("flows_updated", %{
        flows: flows,
        suspicious_nodes: suspicious_nodes,
        local_nodes: local_nodes,
        blocked_ips: blocked_ips
      })

    {:noreply, socket}
  end

  @impl true
  def handle_event("block_ip", %{"ip" => ip}, socket) do
    case ResponseEngine.block_ip(ip) do
      {:ok, message} ->
        blocked_ips = ResponseEngine.get_blocked_ips()

        {:noreply,
         socket
         |> assign(:blocked_ips, blocked_ips)
         |> put_flash(:info, message)}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, reason)}
    end
  end

  @impl true
  def handle_event("node_selected", %{"ip" => ip}, socket) do
    flows = latest_flows()
    selected_flows = Enum.filter(flows, fn flow -> flow.src_ip == ip or flow.dst_ip == ip end)

    {:noreply,
     socket
     |> assign(:selected_node, ip)
     |> assign(:selected_flows, selected_flows)}
  end

  defp latest_flows do
    FlowStore.get_flows()
    |> Enum.sort_by(& &1.total_bytes, :desc)
    |> Enum.take(@max_flows)
  end

  defp detect_local_nodes(flows) do
    flows
    |> Enum.flat_map(fn flow ->
      [{flow.src_ip, flow.direction == "outbound"}, {flow.dst_ip, flow.direction == "inbound"}]
    end)
    |> Enum.filter(fn {_ip, is_local} -> is_local end)
    |> Enum.map(fn {ip, _} -> ip end)
    |> Enum.uniq()
  end

  defp private_or_special_ip?(ip) do
    String.starts_with?(ip, "10.") or
      String.starts_with?(ip, "192.168.") or
      String.starts_with?(ip, "172.") or
      String.starts_with?(ip, "127.") or
      String.starts_with?(ip, "169.254.") or
      String.starts_with?(ip, "224.") or
      String.starts_with?(ip, "239.") or
      ip in ["0.0.0.0", "255.255.255.255"]
  end

  defp blockable_public_ip?(nil), do: false
  defp blockable_public_ip?(ip), do: not private_or_special_ip?(ip)

  defp ip_to_block(alert) do
    src = alert[:src_ip]
    dst = alert[:dst_ip]

    cond do
      blockable_public_ip?(dst) and private_or_special_ip?(src) -> dst
      blockable_public_ip?(src) and private_or_special_ip?(dst) -> src
      blockable_public_ip?(dst) -> dst
      blockable_public_ip?(src) -> src
      true -> nil
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div style="padding: 30px;">
      <h1 style="font-size: 28px; font-weight: bold; margin-bottom: 20px;">
        NetSpect Live Network Graph
      </h1>

      <p style="margin-bottom: 20px; color: gray;">
        Real-time visualization of network flows, suspicious nodes, and blocked IPs
      </p>

      <div style="display: flex; gap: 20px; margin-bottom: 20px; flex-wrap: wrap;">
        <div style="padding: 12px 16px; border: 1px solid #ccc; border-radius: 10px;">
          <strong>Total flows shown:</strong> <%= length(@flows) %>
        </div>

        <div style="padding: 12px 16px; border: 1px solid #ccc; border-radius: 10px;">
          <strong>Total alerts:</strong> <%= length(@alerts) %>
        </div>

        <div style="padding: 12px 16px; border: 1px solid #ccc; border-radius: 10px;">
          <strong>Suspicious nodes:</strong> <%= length(@suspicious_nodes) %>
        </div>

        <div style="padding: 12px 16px; border: 1px solid #ccc; border-radius: 10px;">
          <strong>Blocked IPs:</strong> <%= length(@blocked_ips) %>
        </div>
      </div>

      <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 20px;">
        <div
          id="graph"
          phx-hook="GraphHook"
          phx-update="ignore"
          style="width: 100%; height: 600px; border: 1px solid #ccc; border-radius: 10px;">
        </div>

        <div style="border: 1px solid #ccc; border-radius: 10px; padding: 16px; min-height: 600px;">
          <h2 style="font-size: 20px; font-weight: bold; margin-bottom: 10px;">
            Node Details
          </h2>

          <%= if @selected_node do %>
            <p><strong>Selected IP:</strong> <%= @selected_node %></p>
            <p><strong>Related flows:</strong> <%= length(@selected_flows) %></p>

            <%= if blockable_public_ip?(@selected_node) do %>
              <%= if @selected_node in @blocked_ips do %>
                <p style="margin-top: 10px; color: #b00020;"><strong>Already blocked</strong></p>
              <% else %>
                <button
                  phx-click="block_ip"
                  phx-value-ip={@selected_node}
                  style="margin-top: 10px; padding: 8px 12px; background: #b00020; color: white; border: none; border-radius: 8px; cursor: pointer;">
                  Block IP
                </button>
              <% end %>
            <% else %>
              <p style="margin-top: 10px; color: gray;">This IP is local/private and will not be blocked.</p>
            <% end %>

            <div style="margin-top: 16px;">
              <h3 style="font-size: 16px; font-weight: bold; margin-bottom: 8px;">Flows</h3>

              <%= for flow <- @selected_flows do %>
                <div style="padding: 10px; border: 1px solid #eee; border-radius: 8px; margin-bottom: 8px;">
                  <div><strong><%= flow.src_ip %></strong> → <strong><%= flow.dst_ip %></strong></div>
                  <div><%= flow.protocol %> | packets: <%= flow.packet_count %> | bytes: <%= flow.total_bytes %></div>
                </div>
              <% end %>
            </div>
          <% else %>
            <p style="color: gray;">Click a node in the graph to inspect it.</p>
          <% end %>
        </div>
      </div>

      <div style="margin-top: 30px;">
        <h2 style="font-size: 22px; font-weight: bold; margin-bottom: 10px;">
          Alerts
        </h2>

        <%= if Enum.empty?(@alerts) do %>
          <p style="color: gray;">No alerts detected yet.</p>
        <% else %>
          <div style="display: flex; flex-direction: column; gap: 10px;">
            <%= for alert <- @alerts do %>
              <% block_ip = ip_to_block(alert) %>
              <div style="padding: 12px; border: 1px solid #e5a50a; background: #fff8e1; border-radius: 8px; color: black;">
                <strong>[<%= alert.severity %>]</strong> <%= alert.message %><br />
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

                <%= if block_ip do %>
                  <div style="margin-top: 8px;">
                    <%= if block_ip in @blocked_ips do %>
                      <span style="color: #b00020;"><strong>Blocked:</strong> <%= block_ip %></span>
                    <% else %>
                      <button
                        phx-click="block_ip"
                        phx-value-ip={block_ip}
                        style="padding: 6px 10px; background: #b00020; color: white; border: none; border-radius: 8px; cursor: pointer;">
                        Block <%= block_ip %>
                      </button>
                    <% end %>
                  </div>
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
