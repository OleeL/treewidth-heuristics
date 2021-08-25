import LightGraphs as LG
import Random
import Base.Threads
include(joinpath(pwd(), "src", "Heuristics.jl"))

mutable struct GraphData
    g::LG.AbstractGraph
    e_width::Int
    ub::Int
    best_order::Vector{Int}
    nums::Vector{Int}
    finishTime::Float64 # epoch
    numNodes::Int # num nodes visited
    timeout::Bool
    seed::Int
    randomContext::Random.MersenneTwister
end

function branch_bound(g::LG.AbstractGraph, duration::Float64, seed=time()::Int)
    G = deepcopy(g)
    # best_order, ub = min_width(G)
    best_order = Int[]
    ub = 10000
    x = Int[]
    println(best_order, ub)
    nums = genNumberList(LG.nv(g))
    finishTime = time() + duration
    gd = GraphData(G, 0, ub, best_order, nums, finishTime, 1, false, seed, Random.MersenneTwister(seed))
    dfs(gd, x)
    gd
end


@inline function process(gd::GraphData, x::Vector{Int}, v::Int, nVertices::Int)
    
    # Connecting edges
    gm = joinVerts!(gd.g, v)
    temp_ewidth = gd.e_width
    gd.e_width = max(gd.e_width, LG.degree(gd.g, v))
    LG.rem_vertex!(gd.g, v)
    
    # Handling nums
    temp = gd.nums[v]
    gd.nums[v] = gd.nums[nVertices]
    
    if gd.e_width < gd.ub
        # gd_new = GraphData(gd.g, gd.e_width, gd.ub, gd.best_order, nums_old, gd.finishTime, 1, gd.timeout)
        dfs(gd, [x; temp])
    end

    gd.e_width = temp_ewidth
    unmodify_graph!(gd.g, gm, v)
    gd.nums[v] = temp
end

function dfs(gd::GraphData, x::Vector{Int})
    gd.numNodes += 1
    nVertices = LG.nv(gd.g)
    
    if time() >= gd.finishTime
        # println("timeout!")
        gd.timeout = true
        return
    end

    if nVertices < gd.e_width
        if gd.e_width < gd.ub
            gd.ub = gd.e_width
            gd.best_order = [x; gd.nums[1:nVertices]]
        end
        return
    end

    # If parallel
    if length(x) < 1
        gds = [deepcopy(gd) for _ = 1:Threads.nthreads()]
        for v in gds
            v.randomContext = Random.MersenneTwister(v.seed + Threads.threadid())
        end

        Threads.@threads for v in Random.shuffle(gds[1].randomContext, LG.vertices(gd.g))
            if gd.timeout break end
            process(gds[Threads.threadid()], x, v, nVertices)
        end

        # Pick out best order here
        best_gd = argmin([_gd.ub for _gd in gds])
        println("best ub: ", gds[best_gd].ub)
        println("Did timeout: ", gds[best_gd].timeout)
        gd.numNodes = sum([_gd.numNodes for _gd in gds])
        gd.best_order = gds[best_gd].best_order
        gd.ub = gds[best_gd].ub
        gd.timeout = gds[best_gd].timeout
        
    else
        for v in Random.shuffle(gd.randomContext, LG.vertices(gd.g))
            if gd.timeout break end
            process(gd, x, v, nVertices)
        end
    end
end

# revert changes made to the graph
@inline function unmodify_graph!(g::LG.AbstractGraph, gm::GraphModification, v::Int)
    LG.add_vertex!(g)

    nb = copy(LG.neighbors(g, v))
    
    for i in nb
        LG.add_edge!(g, i, LG.nv(g))
        LG.rem_edge!(g, i, v)
    end

    for i in gm.nb
        LG.add_edge!(g, i, v)
    end

    for i in gm.addedEdges
        LG.rem_edge!(g, i[1], i[2])
    end
end