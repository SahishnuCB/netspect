defmodule NetspectBackend.GraphStore do
  @moduledoc """
  Derives graph-friendly nodes and edges from flows.
  """

  def build_graph(flows) do
    nodes =
      flows
      |> Enum.flat_map(fn flow -> [flow.src_ip, flow.dst_ip] end)
      |> Enum.uniq()
      |> Enum.map(fn ip -> %{id: ip, label: ip} end)

    edges =
      flows
      |> Enum.map(fn flow ->
        %{
          id: "#{flow.src_ip}-#{flow.dst_ip}-#{flow.src_port}-#{flow.dst_port}-#{flow.protocol}",
          source: flow.src_ip,
          target: flow.dst_ip,
          protocol: flow.protocol,
          packet_count: flow.packet_count,
          total_bytes: flow.total_bytes
        }
      end)

    %{nodes: nodes, edges: edges}
  end
end
