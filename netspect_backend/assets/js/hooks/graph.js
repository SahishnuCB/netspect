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
            selector: "node.suspicious",
            style: {
                "background-color": "#d62728",
                "border-width": 3,
                "border-color": "#7f0000",
                "text-outline-color": "#d62728"
            }
            },
            {
            selector: "node.local",
            style: {
                "background-color": "#28a745",
                "border-width": 4,
                "border-color": "#14532d",
                "text-outline-color": "#28a745"
            }
            },
            {
            selector: "node.local.suspicious",
            style: {
                "background-color": "#28a745",
                "border-width": 5,
                "border-color": "#ff0000",
                "text-outline-color": "#28a745"
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

        this.handleEvent("flows_updated", ({ flows, suspicious_nodes }) => {
        this.renderGraph(flows, suspicious_nodes)
        })
    },

    renderGraph(flows, suspiciousNodes) {
        const LOCAL_IP = "172.20.10.2"

        let nodeMap = {}
        let edges = []

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

        let nodeElements = Object.keys(nodeMap).map(ip => {
        let classes = ""

        if (ip === LOCAL_IP) {
            classes += "local "
        }

        if (suspiciousNodes.includes(ip)) {
            classes += "suspicious "
        }

        return {
            data: {
            id: ip,
            label: ip
            },
            classes: classes.trim()
        }
        })

        this.cy.elements().remove()
        this.cy.add([...nodeElements, ...edges])
        this.cy.layout({ name: "cose", animate: false }).run()
    }
}

export default GraphHook