import requests

BACKEND_URL = "http://localhost:4000/api/packet"


def send_packet_to_backend(packet_data):
    try:
        response = requests.post(BACKEND_URL, json=packet_data, timeout=2)

        if response.status_code != 200:
            print(f"[SEND ERROR] Backend returned {response.status_code}")
    except requests.RequestException as error:
        print(f"[SEND ERROR] Could not send packet: {error}")
