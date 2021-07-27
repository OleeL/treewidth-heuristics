include(joinpath(pwd(), "src", "Heuristics.jl"))
include(joinpath(pwd(), "src", "DFS_BB.jl"))
include(joinpath(pwd(), "src", "VertexEliminationOrder.jl"))

import Test
import LightGraphs as LG
import GraphPlot as GP
import BenchmarkTools as BT

# Testing Heuristics
Test.@testset "VertexEliminationOrder.jl" begin
    # Set up
    graph_file = "circuit_graphs/qflex_line_graph_files_decomposed_true_hyper_true/test.gr"
    G = VertexEliminationOrder.graph_from_gr(graph_file)

    # min fill test
    g = copy(G)
    @BT.time mf = min_fill(g)
    Test.@test LG.nv(G) == length(mf[1])

    # min width test
    g = copy(G)
    @BT.time mw = min_width(g)
    Test.@test LG.nv(G) == length(mw[1])
end

# Testing DFS
Test.@testset "DFS" begin
    # Set up

    # graph_file = "circuit_graphs/qflex_line_graph_files_decomposed_true_hyper_true/rectangular_4x4_1-16-1_0.gr"
    G = VertexEliminationOrder.graph_from_gr("circuit_graphs/qflex_line_graph_files_decomposed_true_hyper_true/test.gr")

    # min fill test
    @BT.time r = branch_bound(G)
    println(r)
    Test.@test r !== nothing
end 