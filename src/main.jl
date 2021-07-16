
include(joinpath(pwd(), "src", "VertexEliminationOrder.jl"))

import BenchmarkTools as BT
import LightGraphs as LG
import GraphPlot as GP

function graph_from_gr(filename::String)::LG.SimpleGraph
    lines = readlines(filename)

    # Create a Graph with the correct number of vertices.
    num_vertices, num_edges = parse.(Int, split(lines[1], ' ')[3:end])
    G = LG.SimpleGraph(num_vertices)

    # Add an edge to the graph for every other line in the file.
    for line in lines[2:end]
        src, dst = parse.(Int, split(line, ' '))
        LG.add_edge!(G, src, dst)
    end

    G
end

# Main
graph_file = "circuit_graphs/qflex_line_graph_files_decomposed_true_hyper_true/test.gr"
G = graph_from_gr(graph_file)
g = copy(G)
GP.gplot(g)
# draw(PNG("graph.png", 800, 600), gplot(g, edgestrokec = colorant"black"))

@BT.time tw = min_fill(g)
g = copy(G)
@BT.time tw = min_width(g)