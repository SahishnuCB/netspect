defmodule NetspectBackend.PacketIngest do
  alias NetspectBackend.FlowStore

  def ingest(params) do
    IO.inspect(params, label: "Received packet")

    FlowStore.update_flow(params)
  end
end
