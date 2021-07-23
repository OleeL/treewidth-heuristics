import LightGraphs as LG

export min_fill, min_width

# Helper functions

# joins vertices together if they're already neighbors
@inline function joinVerts!(g::LG.AbstractGraph, v::Int)
    nb = LG.neighbors(g, v)
    numberOfNeighbors = length(nb)
    for i = 1:numberOfNeighbors-1
        for j = i+1:numberOfNeighbors
            LG.add_edge!(g, nb[i], nb[j])
        end
    end
end

# num of edges added if vertex removed
@inline function countEliminatedEdges(g::LG.AbstractGraph, v::Int)
    e = 0
    nb = LG.neighbors(g, v)
    numberOfNeighbors = length(nb)
    for i = 1:(numberOfNeighbors-1)
        for j = (i+1):numberOfNeighbors
            if !LG.has_edge(g, nb[i], nb[j])
                e+=1
            end
        end
    end
    e
end


@inline genNumberList(n::Int) = [i for i = 1:n]

# Heuristics Below

function min_fill(g::LG.AbstractGraph)
    nVertices = LG.nv(g)
    sorted = zeros(Int, nVertices)
    nums = genNumberList(nVertices)
    treeWidth = 0

    for i = 1:nVertices
        removal = argmin(map(v -> countEliminatedEdges(g,v), LG.vertices(g)))
        sorted[i] = nums[removal]

        x = nVertices + 1 - i
        if removal < x
            nums[removal] = x
        end

        treeWidth = max(treeWidth, LG.degree(g, removal))
        joinVerts!(g, removal)
        LG.rem_vertex!(g, removal)
    end

    (sorted, treeWidth)
end

function min_width(g::LG.AbstractGraph)
    nVertices = LG.nv(g)
    sorted = zeros(Int, nVertices)
    nums = genNumberList(nVertices)
    treeWidth = 0

    for i = 1:nVertices
        removal = argmin(LG.degree(g))
        sorted[i] = nums[removal]

        x = nVertices + 1 - i
        if removal < x
            nums[removal] = x
        end

        treeWidth = max(treeWidth, LG.degree(g, removal))
        joinVerts!(g, removal)
        LG.rem_vertex!(g, removal)
    end

    (sorted, treeWidth)
end

function branch_bound(g::LG.AbstractGraph)
    G = deepcopy(g)
    # best_order, ub = min_width(G)
    best_order = Int[]
    ub = 10000
    x = Int[]
    println(best_order, ub)
    nums = genNumberList(LG.nv(g))
    dfs(g, x, 0, ub, best_order, nums)
end

function dfs(g::LG.AbstractGraph, x::Vector{Int}, e_width::Int, ub::Int, best_order::Vector{Int}, nums::Vector{Int})
    new_nums = copy(nums)
    nVertices = LG.nv(g)
    if nVertices < 2
        if e_width < ub
            return (e_width, [x; new_nums[1]])
        else
            return (ub, best_order)
        end
    end

    for v in LG.vertices(g)
        # Creating copies & refs
        l_graph = deepcopy(g)
        x_new = [x; new_nums[v]]

        # Connecting edges
        joinVerts!(l_graph, v)
        e_width = max(e_width, LG.degree(g, v))
        LG.rem_vertex!(l_graph, v)
        new_nums[v] = new_nums[nVertices]
        
        if e_width < ub
            ub, best_order = dfs(l_graph, x_new, e_width, ub, best_order, new_nums)
        end
    end
    (ub, best_order)
end