defmodule NetspectBackend.PacketIngest do
  @moduledoc """
  Entry point for incoming packet metadata from the sniffer.
  Validates packet shape, updates telemetry, sends data to FlowStore,
  and records timeline snapshots.
  """

  alias NetspectBackend.FlowStore
  alias NetspectBackend.TelemetryMetrics
  alias NetspectBackend.TimelineStore

  @required_fields ~w(src_ip dst_ip protocol packet_size direction)a

  def ingest(params) when is_map(params) do
    case validate(params) do
      :ok ->
        TelemetryMetrics.increment_packets()
        FlowStore.update_flow(params)
        TimelineStore.record_packet(params)
        :ok

      {:error, reason} ->
        TelemetryMetrics.increment_ingest_errors()
        {:error, reason}
    end
  end

  defp validate(params) do
    missing =
      @required_fields
      |> Enum.filter(fn field ->
        Map.get(params, Atom.to_string(field)) in [nil, ""]
      end)

    if missing == [] do
      :ok
    else
      {:error, {:missing_fields, missing}}
    end
  end
end
