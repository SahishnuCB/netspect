defmodule NetspectBackendWeb.TimelineComponent do
  use Phoenix.Component

  def render(assigns) do
    ~H"""
    <div style="margin-top: 30px;">
      <h2 style="font-size: 20px; font-weight: bold; margin-bottom: 10px;">
        Activity Timeline
      </h2>

      <div style="display: flex; flex-direction: column; gap: 8px;">
        <%= for event <- @events do %>
          <div style="
            padding: 10px;
            border-left: 4px solid #6366f1;
            background: #0f172a;
            color: white;
            border-radius: 6px;
          ">
            <div style="font-size: 12px; color: #94a3b8;">
              <%= event.timestamp %>
            </div>

            <div style="font-size: 14px;">
              <%= event.message %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
