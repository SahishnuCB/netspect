defmodule NetspectBackend.ResponseEngine do
  use GenServer

  @moduledoc """
  Active response engine for NetSpect.

  Current MVP behavior:
  - validates the target IP
  - blocks the IP using Windows Firewall (netsh)
  - keeps blocked IPs in memory for UI/state
  """

  # ---------- Client API ----------

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, MapSet.new(), name: __MODULE__)
  end

  def block_ip(ip) when is_binary(ip) do
    GenServer.call(__MODULE__, {:block_ip, ip})
  end

  def get_blocked_ips do
    GenServer.call(__MODULE__, :get_blocked_ips)
  end

  # ---------- Server ----------

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call(:get_blocked_ips, _from, state) do
    {:reply, MapSet.to_list(state), state}
  end

  @impl true
  def handle_call({:block_ip, ip}, _from, state) do
    cond do
      not blockable_public_ip?(ip) ->
        {:reply, {:error, "IP is not blockable (private, local, multicast, or invalid)"}, state}

      MapSet.member?(state, ip) ->
        {:reply, {:ok, "IP already blocked"}, state}

      true ->
        out_rule = "NetSpect Block OUT #{ip}"
        in_rule = "NetSpect Block IN #{ip}"

        out_result =
          System.cmd("netsh", [
            "advfirewall", "firewall", "add", "rule",
            "name=#{out_rule}",
            "dir=out",
            "action=block",
            "remoteip=#{ip}"
          ], stderr_to_stdout: true)

        in_result =
          System.cmd("netsh", [
            "advfirewall", "firewall", "add", "rule",
            "name=#{in_rule}",
            "dir=in",
            "action=block",
            "remoteip=#{ip}"
          ], stderr_to_stdout: true)

        case {out_result, in_result} do
          {{_out_msg, 0}, {_in_msg, 0}} ->
            new_state = MapSet.put(state, ip)
            {:reply, {:ok, "Blocked #{ip} via Windows Firewall"}, new_state}

          {{out_msg, out_code}, _} when out_code != 0 ->
            {:reply, {:error, String.trim(out_msg)}, state}

          {_, {in_msg, in_code}} when in_code != 0 ->
            {:reply, {:error, String.trim(in_msg)}, state}
        end
    end
  end

  # ---------- Helpers ----------

  defp blockable_public_ip?(ip) do
    valid_ipv4?(ip) and not private_or_special_ip?(ip)
  end

  defp valid_ipv4?(ip) do
    case :inet.parse_address(String.to_charlist(ip)) do
      {:ok, _addr} -> true
      _ -> false
    end
  end

  defp private_or_special_ip?(ip) do
    String.starts_with?(ip, "10.") or
      String.starts_with?(ip, "192.168.") or
      String.starts_with?(ip, "172.") or
      String.starts_with?(ip, "127.") or
      String.starts_with?(ip, "169.254.") or
      String.starts_with?(ip, "224.") or
      String.starts_with?(ip, "239.") or
      ip in ["0.0.0.0", "255.255.255.255"]
  end
end
