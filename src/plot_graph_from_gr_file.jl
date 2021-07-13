using LightGraphs, GraphPlot

#= 
A simple script to read a graph from a gr file and plot it. =#

"""
    graph_from_gr(filename::String)

Read a graph from the provided gr file.
"""
function graph_from_gr(filename::String)::SimpleGraph
    lines = readlines(filename)

    # Create a Graph with the correct number of vertices.
    num_vertices, num_edges = parse.(Int, split(lines[1], ' ')[3:end])
    G = SimpleGraph(num_vertices)

    # Add an edge to the graph for every other line in the file.
    for line in lines[2:end]
        src, dst = parse.(Int, split(line, ' '))
        add_edge!(G, src, dst)
    end

    G
end