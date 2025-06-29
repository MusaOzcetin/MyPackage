module Types

export Node, Connection, Genome

# Step 1: Define a Genome
# A Genome consists of a: Nodes and b: Connections 

# with Node holding id ; nodetype
# and Connection holding in_node ; out_node ; weight ; enabled ; innovation_number

struct Node
    id::Int
    nodetype::Symbol # input, hidden or output
end

mutable struct Connection
    in_node::Int
    out_node::Int
    weight::Float64
    enabled::Bool
    innovation_number::Int
end

mutable struct Genome
    id::Int
    nodes::Dict{Int,Node}
    connections::Dict{Tuple{Int,Int},Connection}
    fitness::Float64 # for storing fitness score to avoid using locally
    adjusted_fitness::Float64 # normalized fitness value shared across species 
end

end