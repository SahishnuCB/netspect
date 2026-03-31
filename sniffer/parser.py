from scapy.all import IP, TCP, UDP


def is_private_ip(ip: str) -> bool:
    return ip.startswith("10.") or ip.startswith("192.168.") or ip.startswith("172.")


def parse_packet(packet):
    # Ignore anything without an IP layer
    if IP not in packet:
        return None

    src_ip = packet[IP].src
    dst_ip = packet[IP].dst

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
    }

    if TCP in packet:
        parsed["protocol"] = "TCP"
        parsed["src_port"] = packet[TCP].sport
        parsed["dst_port"] = packet[TCP].dport
    elif UDP in packet:
        parsed["protocol"] = "UDP"
        parsed["src_port"] = packet[UDP].sport
        parsed["dst_port"] = packet[UDP].dport

    # Try to infer traffic direction roughly
    if parsed["is_src_private"] and not parsed["is_dst_private"]:
        parsed["direction"] = "outbound"
    elif not parsed["is_src_private"] and parsed["is_dst_private"]:
        parsed["direction"] = "inbound"
    elif parsed["is_src_private"] and parsed["is_dst_private"]:
        parsed["direction"] = "local"

    return parsed
