defmodule NetspectBackend.GeoipService do
  @moduledoc """
  Placeholder GeoIP service for MVP architecture.
  You can later replace this with a real GeoIP lookup provider.
  """

  def lookup(ip) when is_binary(ip) do
    cond do
      String.starts_with?(ip, "10.") ->
        %{ip: ip, scope: "private", location: "local network"}

      String.starts_with?(ip, "192.168.") ->
        %{ip: ip, scope: "private", location: "local network"}

      String.starts_with?(ip, "172.") ->
        %{ip: ip, scope: "private", location: "local/private range"}

      true ->
        %{ip: ip, scope: "public", location: "unknown"}
    end
  end
end
