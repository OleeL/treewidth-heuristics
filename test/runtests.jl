include(joinpath(pwd(), "src", "Heuristics.jl"))
include(joinpath(pwd(), "src", "DFS_BB.jl"))
include(joinpath(pwd(), "src", "VertexEliminationOrder.jl"))

import Test
import LightGraphs as LG
import GraphPlot as GP
import BenchmarkTools as BT
import ProfileView as PV

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
    # graph_file = "circuit_graphs/qflex_line_graph_files_decomposed_true_hyper_true/test.gr"
    # graph_file = "circuit_graphs/qflex_line_graph_files_decomposed_true_hyper_true/sycamore_53_20_0.gr" # very big
    graph_file = "circuit_graphs/qflex_line_graph_files_decomposed_true_hyper_true/sycamore_53_8_0.gr" # very big
    G = VertexEliminationOrder.graph_from_gr(graph_file) 

    # min fill test
    seconds = 5.0
    println("Max alg duration: ", seconds, " seconds")
    @time r = branch_bound(G, seconds, 10)
    # @PV.profview r = branch_bound(G, seconds)

    println("Upper bound: ", r.ub)
    println("Best order: ", r.best_order)
    println("Timed out: ", r.timeout)
    println("Number of nodes visited: ", r.numNodes)
    println("Graph: ", r.g)
    
    # Checking to see if the function returns something
    Test.@test r !== nothing

    # Checking to see if the best order has unique values
    Test.@test length(unique(r.best_order)) == length(r.best_order)
end 