include(joinpath(pwd(), "src", "VertexEliminationOrder.jl"))

import Test, LightGraphs as LG

# Testing Heuristics
Test.@testset "VertexEliminationOrder.jl" begin
    # Set up
    graph_file = "circuit_graphs/qflex_line_graph_files_decomposed_true_hyper_true/test.gr"
    G = graph_from_gr(graph_file)

    # min fill test
    g = copy(G)
    @BT.time mf = min_fill(g)
    Test.@test LG.nv(G) == length(mf[1])

    # min width test
    g = copy(G)
    @BT.time mw = min_width(g)
    Test.@test LG.nv(G) == length(mw[1])
end
