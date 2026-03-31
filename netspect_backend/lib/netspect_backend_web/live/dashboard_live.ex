defmodule NetspectBackendWeb.DashboardLive do
  use NetspectBackendWeb, :live_view

  alias NetspectBackend.FlowStore

  @refresh_interval 1000

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(@refresh_interval, self(), :refresh_flows)
    end

    {:ok,
      socket
      |> assign(:page_title, "NetSpect Dashboard")
      |> assign(:flows, FlowStore.get_flows())}
  end

  @impl true
  def handle_info(:refresh_flows, socket) do
    {:noreply, assign(socket, :flows, FlowStore.get_flows())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="p-8">
      <h1 class="text-3xl font-bold mb-2">NetSpect Dashboard</h1>
      <p class="text-gray-600 mb-6">
        Real-time network flows captured from the Python sniffer
      </p>

      <div class="mb-4">
        <span class="font-semibold">Total flows:</span> <%= length(@flows) %>
      </div>

      <div class="overflow-x-auto border rounded-lg">
        <table class="min-w-full text-sm">
          <thead class="bg-gray-100">
            <tr>
              <th class="text-left p-3">Protocol</th>
              <th class="text-left p-3">Direction</th>
              <th class="text-left p-3">Source IP</th>
              <th class="text-left p-3">Src Port</th>
              <th class="text-left p-3">Destination IP</th>
              <th class="text-left p-3">Dst Port</th>
              <th class="text-left p-3">Packets</th>
              <th class="text-left p-3">Bytes</th>
            </tr>
          </thead>
          <tbody>
            <%= for flow <- @flows do %>
              <tr class="border-t">
                <td class="p-3"><%= flow.protocol %></td>
                <td class="p-3"><%= flow.direction %></td>
                <td class="p-3"><%= flow.src_ip %></td>
                <td class="p-3"><%= flow.src_port %></td>
                <td class="p-3"><%= flow.dst_ip %></td>
                <td class="p-3"><%= flow.dst_port %></td>
                <td class="p-3"><%= flow.packet_count %></td>
                <td class="p-3"><%= flow.total_bytes %></td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end
end
