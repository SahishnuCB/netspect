import cytoscape from "cytoscape"

let GraphHook = {
    mounted() {
        this.cy = cytoscape({
        container: this.el,
        elements: [],
        style: [
            {
            selector: "node",
            style: {
                "background-color": "#007bff",
                "label": "data(label)",
                "color": "#ffffff",
                "text-valign": "center",
                "text-halign": "center",
                "font-size": "10px",
                "text-outline-width": 2,
                "text-outline-color": "#007bff"
            }
            },
            {
            selector: "node.local",
            style: {
                "background-color": "#28a745",
                "border-width": 3,
                "border-color": "#14532d",
                "text-outline-color": "#28a745"
            }
            },
            {
            selector: "node.suspicious",
            style: {
                "background-color": "#d62728",
                "border-width": 3,
                "border-color": "#7f0000",
                "text-outline-color": "#d62728"
            }
            },
            {
            selector: "node.blocked",
            style: {
                "background-color": "#111111",
                "border-width": 4,
                "border-color": "#ffcc00",
                "text-outline-color": "#111111"
            }
            },
            {
            selector: "edge",
            style: {
                "width": 2,
                "line-color": "#999",
                "target-arrow-shape": "triangle",
                "target-arrow-color": "#999",
                "curve-style": "bezier"
            }
            }
        ],
        layout: {
            name: "cose",
            animate: false
        }
        })

        // click node
        this.cy.on("tap", "node", (evt) => {
        const ip = evt.target.id()
        this.pushEvent("node_selected", { ip: ip })
        })

        // updates from backend
        this.handleEvent("flows_updated", ({ flows, suspicious_nodes, local_nodes, blocked_ips }) => {
        this.renderGraph(flows, suspicious_nodes, local_nodes, blocked_ips)
        })
    },

    renderGraph(flows, suspiciousNodes, localNodes, blockedIps) {
        let nodeMap = {}
        let edges = []

        // collect nodes + edges
        flows.forEach(flow => {
        nodeMap[flow.src_ip] = true
        nodeMap[flow.dst_ip] = true

        edges.push({
            data: {
            id: `${flow.src_ip}-${flow.dst_ip}-${flow.src_port}-${flow.dst_port}-${flow.protocol}`,
            source: flow.src_ip,
            target: flow.dst_ip
            }
        })
        })

        let allNodes = Object.keys(nodeMap)

        // 🔥 find YOUR machine (most frequent local IP)
        let localCount = {}

        flows.forEach(flow => {
        if (localNodes.includes(flow.src_ip)) {
            localCount[flow.src_ip] = (localCount[flow.src_ip] || 0) + 1
        }
        if (localNodes.includes(flow.dst_ip)) {
            localCount[flow.dst_ip] = (localCount[flow.dst_ip] || 0) + 1
        }
        })

        let mainLocalIP = null
        let maxCount = 0

        Object.entries(localCount).forEach(([ip, count]) => {
        if (count > maxCount) {
            maxCount = count
            mainLocalIP = ip
        }
        })

        // ✅ keep only:
        // - your machine
        // - non-local (internet)
        let filteredNodes = allNodes.filter(ip => {
        if (ip === mainLocalIP) return true
        if (!localNodes.includes(ip)) return true
        return false
        })

        // build nodes
        let nodeElements = filteredNodes.map(ip => {
        let classes = ""

        if (ip === mainLocalIP) {
            classes += "local "
        }

        if (suspiciousNodes.includes(ip) && ip !== mainLocalIP) {
            classes += "suspicious "
        }

        if (blockedIps.includes(ip)) {
            classes += "blocked "
        }

        return {
            data: {
            id: ip,
            label: ip
            },
            classes: classes.trim()
        }
        })

        // keep only valid edges
        let filteredEdges = edges.filter(edge =>
        filteredNodes.includes(edge.data.source) &&
        filteredNodes.includes(edge.data.target)
        )

        // render
        this.cy.elements().remove()
        this.cy.add([...nodeElements, ...filteredEdges])
        this.cy.layout({ name: "cose", animate: false }).run()
    }
}

export default GraphHook