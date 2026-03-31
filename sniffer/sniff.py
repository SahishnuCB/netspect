from scapy.all import sniff
from parser import parse_packet
from sender import send_packet_to_backend


def should_skip_packet(parsed):
    if parsed is None:
        return True

    dst_ip = parsed["dst_ip"]
    src_ip = parsed["src_ip"]
    dst_port = parsed["dst_port"]
    src_port = parsed["src_port"]

    # Ignore multicast / broadcast / invalid
    if dst_ip.startswith("224.") or dst_ip.startswith("239."):
        return True
    if dst_ip == "255.255.255.255" or dst_ip == "0.0.0.0":
        return True
    if src_ip == "0.0.0.0":
        return True

    # Ignore noisy discovery / local broadcast traffic
    noisy_ports = {5353, 137, 138, 1900, 67, 68}
    if dst_port in noisy_ports or src_port in noisy_ports:
        return True

    # Ignore local-only traffic
    if parsed["direction"] == "local":
        return True

    # Ignore non TCP/UDP
    if parsed["protocol"] not in ["TCP", "UDP"]:
        return True

    return False


def handle_packet(packet):
    parsed = parse_packet(packet)

    if should_skip_packet(parsed):
        return

    print(
        f"[{parsed['protocol']}] "
        f"{parsed['src_ip']}:{parsed['src_port']} -> "
        f"{parsed['dst_ip']}:{parsed['dst_port']} "
        f"dir={parsed['direction']} size={parsed['packet_size']}"
    )

    send_packet_to_backend(parsed)


def start_sniffing():
    print("Starting packet capture...")

    sniff(prn=handle_packet, store=False)
