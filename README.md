# 📡 NetSpect — Real-Time Network Flow Visualizer

## 🚀 Overview

NetSpect is a real-time network monitoring system that transforms low-level packet data into high-level communication patterns.

Instead of displaying raw packets like traditional tools, NetSpect groups traffic into flows and visualizes them as a live graph, making it easier to understand how devices communicate over a network.

---

## 🧠 Key Idea

> Turn messy packet-level data into clean, real-time communication patterns.

---

## ⚙️ How It Works

### 1. Packet Capture (Python + Scapy)
- Captures live network packets
- Extracts metadata:
  - source IP
  - destination IP
  - ports
  - protocol
  - packet size

---

### 2. Flow Aggregation
- Groups packets into flows using:
  (src_ip, dst_ip, src_port, dst_port, protocol)

- Tracks:
  - packet count
  - total bytes

👉 A flow represents a conversation between devices

---

### 3. Backend Processing (Elixir + Phoenix)
- Receives packet data via API
- Maintains flow state in memory
- Updates flow statistics in real time

---

### 4. Anomaly Detection (Rule-Based)
- Flags:
  - high packet count
  - high data transfer
  - unusual ports

---

### 5. Real-Time Visualization (Phoenix LiveView + Cytoscape.js)
- Nodes → devices (IP addresses)
- Edges → communication flows
- Live updates via WebSockets

---

## 📊 Features

- ✅ Real-time packet capture  
- ✅ Flow-based aggregation  
- ✅ Live network graph  
- ✅ Basic anomaly detection  
- ✅ Backend observability via API  
- ✅ Lightweight and fast  

---

## 🌐 API Endpoint

### GET /api/health

Returns:
- active flows  
- generated alerts  
- system metrics  

Example:

```json
{
  "flow_count": 6,
  "alert_count": 3,
  "flows": [...],
  "alerts": [...]
}
```

---

## 🧪 Example Use Case

Even when bandwidth appears idle, NetSpect reveals:

- background system communication  
- DNS requests  
- persistent connections  
- real-time network behavior  

---

## 🧠 Why Flow-Based Analysis?

Traditional tools like Wireshark operate at the packet level:

- extremely detailed  
- hard to interpret in real time  

NetSpect uses flows to:

- reduce noise  
- improve clarity  
- focus on communication patterns  

---

## ⚠️ Current Limitations

- In-memory storage (data lost on restart)  
- Rule-based detection (not adaptive yet)  
- No DNS resolution (IP only)  
- Single-node architecture  

---

## 🔮 Future Improvements

- Configurable detection rules  
- DNS resolution (IP → domain names)  
- Persistent storage (database)  
- Behavioral anomaly detection  
- Automated response (e.g., IP blocking)  
- UI enhancements  

---

## 🧰 Tech Stack

- Python + Scapy → Packet capture  
- Elixir + Phoenix LiveView → Backend + real-time updates  
- Cytoscape.js → Graph visualization  

---

## 💡 Key Insight

> Many applications share backend infrastructure (CDNs), so fewer nodes may appear than expected.

---

## 🏁 Conclusion

NetSpect demonstrates a complete pipeline:

Packet Capture → Flow Aggregation → Detection → Real-Time Visualization

It focuses on behavior over raw data, making network activity easier to understand and analyze.

---

## 👨‍💻 Author

Built as a hackathon project to explore real-time systems, networking, and visualization.