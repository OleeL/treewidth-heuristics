module helpers

using LightGraphs, GraphPlot, Plots

# joins vertices together if they're already neighbors
@inline function joinVerts!(g::AbstractGraph, v::Int)
    nb = neighbors(g, v)
    numberOfNeighbors = length(nb)
    requireChange = false
    for i = 1:numberOfNeighbors-1
        for j = i+1:numberOfNeighbors
            if !has_edge(g, nb[i], nb[j])
                add_edge!(g, nb[i], nb[j])
                requireChange = true
            end
        end
    end
end

# num of edges added if vertex removed
@inline function countEliminatedEdges(g::AbstractGraph{Int}, v::Int)
    e = 0
    nb = neighbors(g, v)
    numberOfNeighbors = length(nb)
    for i = 1:(numberOfNeighbors-1)
        for j = (i+1):numberOfNeighbors
            if !has_edge(g, nb[i], nb[j])
                e+=1
            end
        end
    end
    e
end


@inline genNumberList(n::Int) = [i for i = 1:n]

end