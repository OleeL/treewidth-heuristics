import LightGraphs as LG
import Random
import Base.Threads

mutable struct GraphData
    g::LG.AbstractGraph
    e_width::Int
    ub::Int
    best_order::Vector{Int}
    nums::Vector{Int}
    finishTime::Float64 # epoch
    numNodes::Int
end

function branch_bound(g::LG.AbstractGraph, duration::Int)
    G = deepcopy(g)
    # best_order, ub = min_width(G)
    best_order = Int[]
    ub = 10000
    x = Int[]
    println(best_order, ub)
    nums = genNumberList(LG.nv(g))
    finishTime = time() + duration
    
    dfs(GraphData(G, 0, ub, best_order, nums, finishTime, 1), x)
end


@inline function process(gd::GraphData, x::Vector{Int}, v::Int, nVertices::Int)
    # Creating copies & refs
    l_graph = copy(gd.g)
    x_new = [x; gd.nums[v]]
    
    # Connecting edges
    joinVerts!(l_graph, v)
    gd.e_width = max(gd.e_width, LG.degree(gd.g, v))
    LG.rem_vertex!(l_graph, v)
    nums_old = copy(gd.nums)
    nums_old[v] = nums_old[nVertices]
    
    if gd.e_width < gd.ub
        gd_new = GraphData(l_graph, gd.e_width, gd.ub, gd.best_order, nums_old, gd.finishTime, 1)
        gd.ub, gd.best_order, n = dfs(gd_new, x_new)
        gd.numNodes += n
    end
end

function dfs(gd::GraphData, x::Vector{Int})
    nVertices = LG.nv(gd.g)
    
    if time() >= gd.finishTime
        return (gd.e_width, [x; gd.nums[1]], 1)
    end

    if nVertices < 2
        return gd.e_width < gd.ub ? (gd.e_width, [x; gd.nums[1]], 1) : (gd.ub, gd.best_order, 1)
    end

    parallel = length(x) < 1

    if parallel
        Threads.@threads for v in Random.shuffle(LG.vertices(gd.g))
            process(gd, x, v, nVertices)
        end
    else
        for v in Random.shuffle(LG.vertices(gd.g))
            process(gd, x, v, nVertices)
        end
    end

    (gd.ub, gd.best_order, gd.numNodes)
end