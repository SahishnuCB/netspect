defmodule NetspectBackendWeb.MetricsPanel do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div style="display:flex; gap:16px; flex-wrap:wrap; margin-bottom:20px;">

      <div style="padding:16px; border:1px solid #333; border-radius:10px;">
        <p style="color:gray;">Packets</p>
        <h2><%= @metrics.packets_received %></h2>
      </div>

      <div style="padding:16px; border:1px solid #333; border-radius:10px;">
        <p style="color:gray;">Alerts</p>
        <h2><%= @metrics.alerts_generated %></h2>
      </div>

      <div style="padding:16px; border:1px solid #333; border-radius:10px;">
        <p style="color:gray;">Errors</p>
        <h2><%= @metrics.ingest_errors %></h2>
      </div>

    </div>
    """
  end
end
