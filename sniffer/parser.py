# extracts src/dst IP, ports, etc

from scapy.all import IP, TCP, UDP


def parse_packet(packet):
    # checkiung if the packet has an IP layer
    if IP in packet:
        return None
    
    parsed = {
        
    }
