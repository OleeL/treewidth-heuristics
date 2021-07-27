import LightGraphs as LG

mutable struct GraphData
    g::LG.AbstractGraph
    e_width::Int
    ub::Int
    best_order::Vector{Int}
    nums::Vector{Int}
end

function branch_bound(g::LG.AbstractGraph)
    G = deepcopy(g)
    # best_order, ub = min_width(G)
    best_order = Int[]
    ub = 10000
    x = Int[]
    println(best_order, ub)
    nums = genNumberList(LG.nv(g))
    dfs(GraphData(g, 0, ub, best_order, nums), x)
end

function dfs(gd::GraphData, x::Vector{Int})
    new_nums = copy(gd.nums)
    nVertices = LG.nv(gd.g)
    if nVertices < 2
        if gd.e_width < gd.ub
            return (gd.e_width, [gd; gd.nums[1]])
        else
            return (gd.ub, gd.best_order)
        end
    end

    for v in LG.vertices(gd.g)
        # Creating copies & refs
        l_graph = copy(gd.g)
        x_new = [x; new_nums[v]]

        # Connecting edges
        joinVerts!(l_graph, v)
        gd.e_width = max(gd.e_width, LG.degree(gd.g, v))
        LG.rem_vertex!(l_graph, v)
        new_nums[v] = new_nums[nVertices]
        
        if gd.e_width < gd.ub
            gd.ub, gd.best_order = dfs(gd, x_new)
        end
    end
    (gd.ub, gd.best_order)
end