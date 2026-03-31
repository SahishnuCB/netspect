defmodule NetspectBackendWeb.PacketController do
  use NetspectBackendWeb, :controller

  alias NetspectBackend.PacketIngest

  def create(conn, params) do
    PacketIngest.ingest(params)

    json(conn, %{message: "Packet received"})
  end
end
