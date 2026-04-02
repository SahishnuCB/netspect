from scapy.all import sniff
from parser import parse_packet
from sender import send_packet_to_backend


def should_skip_packet(parsed):
    if parsed is None:
        return True

    src_ip = parsed["src_ip"]
    dst_ip = parsed["dst_ip"]
    src_port = parsed["src_port"]
    dst_port = parsed["dst_port"]

    # Ignore multicast / broadcast
    if dst_ip.startswith("224.") or dst_ip.startswith("239."):
        return True

    if dst_ip == "255.255.255.255":
        return True

    # Reduce noise ports (keep this)
    noisy_ports = {5353, 137, 138, 1900}
    if src_port in noisy_ports or dst_port in noisy_ports:
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
