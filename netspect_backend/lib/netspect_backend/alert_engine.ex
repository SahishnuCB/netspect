defmodule NetspectBackend.AlertEngine do
  @moduledoc """
  Simple rule-based alert engine for NetSpect.
  """

  @packet_threshold 20
  @byte_threshold 50_000
  @common_ports [80, 443, 53, 22, 25, 110, 143, 123]

  def analyze_flow(flow) do
    []
    |> maybe_add_high_packet_alert(flow)
    |> maybe_add_high_byte_alert(flow)
    |> maybe_add_unusual_port_alert(flow)
  end

  def suspicious_flow?(flow) do
    analyze_flow(flow) != []
  end

  def suspicious_nodes(flows) do
    flows
    |> Enum.filter(&suspicious_flow?/1)
    |> Enum.flat_map(fn flow -> [flow.src_ip, flow.dst_ip] end)
    |> Enum.uniq()
  end

  defp maybe_add_high_packet_alert(alerts, flow) do
    if flow.packet_count > @packet_threshold do
      [
        %{
          type: "high_packet_count",
          severity: "medium",
          message: "Flow exceeded packet threshold",
          src_ip: flow.src_ip,
          dst_ip: flow.dst_ip,
          packet_count: flow.packet_count
        }
        | alerts
      ]
    else
      alerts
    end
  end

  defp maybe_add_high_byte_alert(alerts, flow) do
    if flow.total_bytes > @byte_threshold do
      [
        %{
          type: "high_data_transfer",
          severity: "high",
          message: "Flow exceeded data transfer threshold",
          src_ip: flow.src_ip,
          dst_ip: flow.dst_ip,
          total_bytes: flow.total_bytes
        }
        | alerts
      ]
    else
      alerts
    end
  end

  # Only check unusual destination ports for outbound flows
  defp maybe_add_unusual_port_alert(alerts, flow) do
    cond do
      flow.direction != "outbound" ->
        alerts

      is_nil(flow.dst_port) ->
        alerts

      flow.dst_port in @common_ports ->
        alerts

      true ->
        [
          %{
            type: "unusual_port",
            severity: "low",
            message: "Outbound flow is using an unusual destination port",
            src_ip: flow.src_ip,
            dst_ip: flow.dst_ip,
            dst_port: flow.dst_port
          }
          | alerts
        ]
    end
  end
end
