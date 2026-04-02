defmodule NetspectBackend.TimelineStore do
  use GenServer

  @moduledoc """
  Stores a rolling timeline of recent packet/flow events.
  """

  @max_events 100

  # ---------- Client API ----------

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def record_packet(packet) do
    GenServer.cast(__MODULE__, {:record_packet, packet})
  end

  def get_events do
    GenServer.call(__MODULE__, :get_events)
  end

  # ---------- Server ----------

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_cast({:record_packet, packet}, state) do
    event = %{
      timestamp: DateTime.utc_now(),
      type: "packet",
      data: packet
    }

    new_state =
      [event | state]
      |> Enum.take(@max_events)

    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_events, _from, state) do
    {:reply, Enum.reverse(state), state}
  end
end
