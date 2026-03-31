from scapy.all import sniff
from parser import parse_packet
from sender import send_packet_to_backend


def should_skip_packet(parsed):
    # Ignore useless/unwanted packet categories
    if parsed is None:
        return True

    # Ignore multicast/broadcast discovery traffic
    if parsed["dst_ip"].startswith("224."):
        return True

    if parsed["dst_port"] in [5353, 137, 138, 1900]:
        return True

    # Ignore local-only traffic
    if parsed["direction"] == "local":
        return True

    # Ignore non TCP/UDP "OTHER" packets for now
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

    # Send clean packet metadata to backend
    send_packet_to_backend(parsed)


def start_sniffing():
    print("Starting packet capture...")

    sniff(prn=handle_packet, store=False)
