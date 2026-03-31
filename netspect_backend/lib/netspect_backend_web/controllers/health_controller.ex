defmodule NetspectBackendWeb.HealthController do
  use NetspectBackendWeb, :controller

  alias NetspectBackend.FlowStore

  def index(conn, _params) do
    json(conn, %{
      status: "ok",
      flows: FlowStore.get_flows()
    })
  end
end
