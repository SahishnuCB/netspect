defmodule NetspectBackend.DnsResolver do
  @moduledoc """
  Minimal reverse DNS resolver.
  """

  def resolve(ip) when is_binary(ip) do
    case :inet.parse_address(String.to_charlist(ip)) do
      {:ok, addr} ->
        case :inet.gethostbyaddr(addr) do
          {:ok, {:hostent, hostname, _, _, _, _}} ->
            to_string(hostname)

          _ ->
            ip
        end

      _ ->
        ip
    end
  end
end
