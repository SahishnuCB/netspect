import cytoscape from "cytoscape"

console.log("GRAPH FILE LOADED")

let GraphHook = {
    mounted() {
        console.log("GRAPH MOUNTED")

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
                "font-size": "10px"
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
            name: "cose"
        } 
        })

        this.handleEvent("flows_updated", ({ flows }) => {
        console.log("LIVE FLOWS RECEIVED:", flows)
        this.renderGraph(flows)
        })
    },

    renderGraph(flows) {
        let nodes = {}
        let edges = []

        flows.forEach(flow => {
        nodes[flow.src_ip] = true
        nodes[flow.dst_ip] = true

        edges.push({
            data: {
            id: `${flow.src_ip}-${flow.dst_ip}-${flow.src_port}-${flow.dst_port}-${flow.protocol}`,
            source: flow.src_ip,
            target: flow.dst_ip
            }
        })
        })

        let nodeElements = Object.keys(nodes).map(ip => ({
        data: {
            id: ip,
            label: ip
        }
        }))

        this.cy.elements().remove()
        this.cy.add([...nodeElements, ...edges])
        this.cy.layout({ name: "cose" }).run()
    }
}

export default GraphHook