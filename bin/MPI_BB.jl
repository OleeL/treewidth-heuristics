using MPI

include(joinpath(pwd(), "src", "Heuristics.jl"))
include(joinpath(pwd(), "src", "DFS_BB.jl"))
include(joinpath(pwd(), "src", "VertexEliminationOrder.jl"))

MPI.Init()
comm = MPI.COMM_WORLD

# Set up
graph_file = "circuit_graphs/qflex_line_graph_files_decomposed_true_hyper_true/sycamore_53_8_0.gr" # very big
G = VertexEliminationOrder.graph_from_gr(graph_file) 

# MPI.Comm_size(comm)
rank = MPI.Comm_rank(comm)
ranks = MPI.Comm_size(comm)
root = 0
seconds = 30.0
seed = 10
actual_seed = seed + rank

println("Max alg duration: ", seconds, " seconds")
@time r = branch_bound(G, seconds, actual_seed)
ubs = MPI.Allgather(r.ub, comm)

best_gd = argmin([ub for ub in ubs])
if best_gd == rank + 1
    println("Upper bound: ", r.ub)
    println("Best order: ", r.best_order)
    println("Number of nodes visited: ", r.numNodes)
    println("Graph: ", r.g)
end

MPI.Finalize()