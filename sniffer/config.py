import socket
import psutil


BACKEND_URL = "http://localhost:4000/api/packet"


def get_active_local_ips():
    """
    Returns a set of non-loopback IPv4 addresses from active interfaces.
    """
    local_ips = set()

    for _iface_name, iface_addrs in psutil.net_if_addrs().items():
        for addr in iface_addrs:
            if addr.family == socket.AF_INET:
                ip = addr.address

                if ip.startswith("127."):
                    continue

                local_ips.add(ip)

    return local_ips
