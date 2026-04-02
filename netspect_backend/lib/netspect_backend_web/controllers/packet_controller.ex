defmodule NetspectBackendWeb.PacketController do
  use NetspectBackendWeb, :controller

  alias NetspectBackend.PacketIngest

  def create(conn, params) do
    case PacketIngest.ingest(params) do
      :ok ->
        json(conn, %{message: "Packet received"})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{error: "Invalid packet payload", reason: inspect(reason)})
    end
  end
end
