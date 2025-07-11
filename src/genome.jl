

export Node, Connection, Genome

# A Node represents a neuron in the network
# - id: unique identifier
# - nodetype: :input, :hidden, or :output
struct Node
    id::Int
    nodetype::Symbol
end

# A Connection is a directed, weighted link between two Nodes
# - in_node, out_node: node IDs it connects
# - weight: strength of the conection
# - enabled: flag if active
# - innovation_number: unique ID for tracking mutations
mutable struct Connection
    in_node::Int
    out_node::Int
    weight::Float64
    enabled::Bool
    innovation_number::Int
end

# A Genome encapsulates a network’s blueprint and its evaluation metrics
# - id: unique genome identifier
# - nodes: mapping from node ID → Node
# - connections: mapping (in_node, out_node) → Connection
# - fitness: raw performance score
# - adjusted_fitness: fitness shared or scaled across species
mutable struct Genome
    id::Int
    nodes::Dict{Int,Node}
    connections::Dict{Tuple{Int,Int},Connection}
    fitness::Float64
    adjusted_fitness::Float64
end
