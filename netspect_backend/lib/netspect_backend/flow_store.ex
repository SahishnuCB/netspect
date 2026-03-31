defmodule NetspectBackend.FlowStore do
  use GenServer

  # ---------- Client API ----------

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def update_flow(packet) do
    GenServer.cast(__MODULE__, {:update_flow, packet})
  end

  def get_flows do
    GenServer.call(__MODULE__, :get_flows)
  end

  # ---------- Server ----------

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:update_flow, packet}, state) do
    key =
      {
        packet["src_ip"],
        packet["dst_ip"],
        packet["src_port"],
        packet["dst_port"],
        packet["protocol"]
      }

    current_flow =
      Map.get(state, key, %{
        src_ip: packet["src_ip"],
        dst_ip: packet["dst_ip"],
        src_port: packet["src_port"],
        dst_port: packet["dst_port"],
        protocol: packet["protocol"],
        packet_count: 0,
        total_bytes: 0,
        direction: packet["direction"]
      })

    updated_flow =
      current_flow
      |> Map.update!(:packet_count, &(&1 + 1))
      |> Map.update!(:total_bytes, &(&1 + (packet["packet_size"] || 0)))

    {:noreply, Map.put(state, key, updated_flow)}
  end

  @impl true
  def handle_call(:get_flows, _from, state) do
    {:reply, Map.values(state), state}
  end
end
