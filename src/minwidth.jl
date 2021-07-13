module minwidth

using LightGraphs, GraphPlot, Plots
include(joinpath(pwd(), "src", "helpers.jl"))
import .helpers
include(joinpath(pwd(), "src", "plot_graph_from_gr_file.jl"))

# Main
graph_file = "circuit_graphs/qflex_line_graph_files_decomposed_true_hyper_true/test.gr"

# Create and plot the graph.
g = graph_from_gr(graph_file)

nVertices = nv(g)

sorted = zeros(Int32, nVertices)
nums = helpers.genNumberList(nVertices)

treeWidth = 0

for i = 1:nVertices
    removal = argmin(map(v -> degree(g,v), vertices(g)))
    sorted[i] = nums[removal]

    x = nVertices + 1 - i
    if removal < x
        sorted[x] = removal
        sorted[removal] = x
    end

    treeWidth = max(treeWidth, degree(g, removal))
    helpers.joinVerts!(g, removal)
    rem_vertex!(g, removal)
end

println("tree width: ", treeWidth)


end # module