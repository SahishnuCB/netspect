from scapy.all import IP, TCP, UDP
from config import get_active_local_ips


def is_private_ip(ip: str) -> bool:
    return ip.startswith("10.") or ip.startswith("192.168.") or ip.startswith("172.")


def parse_packet(packet):
    if IP not in packet:
        return None

    src_ip = packet[IP].src
    dst_ip = packet[IP].dst

    local_ips = get_active_local_ips()

    parsed = {
        "src_ip": src_ip,
        "dst_ip": dst_ip,
        "protocol": "OTHER",
        "src_port": None,
        "dst_port": None,
        "packet_size": len(packet),
        "direction": "unknown",
        "is_src_private": is_private_ip(src_ip),
        "is_dst_private": is_private_ip(dst_ip),
        "is_src_local": src_ip in local_ips,
        "is_dst_local": dst_ip in local_ips,
        "local_ips": list(local_ips),
    }

    if TCP in packet:
        parsed["protocol"] = "TCP"
        parsed["src_port"] = packet[TCP].sport
        parsed["dst_port"] = packet[TCP].dport
    elif UDP in packet:
        parsed["protocol"] = "UDP"
        parsed["src_port"] = packet[UDP].sport
        parsed["dst_port"] = packet[UDP].dport

    if parsed["is_src_local"] and not parsed["is_dst_local"]:
        parsed["direction"] = "outbound"
    elif not parsed["is_src_local"] and parsed["is_dst_local"]:
        parsed["direction"] = "inbound"
    elif parsed["is_src_local"] and parsed["is_dst_local"]:
        parsed["direction"] = "local"
    elif parsed["is_src_private"] and not parsed["is_dst_private"]:
        parsed["direction"] = "outbound"
    elif not parsed["is_src_private"] and parsed["is_dst_private"]:
        parsed["direction"] = "inbound"
    elif parsed["is_src_private"] and parsed["is_dst_private"]:
        parsed["direction"] = "local"

    return parsed
