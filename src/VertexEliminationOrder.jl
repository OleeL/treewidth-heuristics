import LightGraphs as LG

export min_fill, min_width

# Helper functions

# joins vertices together if they're already neighbors
@inline function joinVerts!(g::LG.AbstractGraph, v::Int)
    nb = LG.neighbors(g, v)
    numberOfNeighbors = length(nb)
    requireChange = false
    for i = 1:numberOfNeighbors-1
        for j = i+1:numberOfNeighbors
            if !LG.has_edge(g, nb[i], nb[j])
                LG.add_edge!(g, nb[i], nb[j])
                requireChange = true
            end
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
            nums[x] = removal
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
        removal = argmin(map(v -> LG.degree(g,v), LG.vertices(g)))
        sorted[i] = nums[removal]

        x = nVertices + 1 - i
        if removal < x
            nums[x] = removal
            nums[removal] = x
        end

        treeWidth = max(treeWidth, LG.degree(g, removal))
        joinVerts!(g, removal)
        LG.rem_vertex!(g, removal)
    end

    (sorted, treeWidth)
end