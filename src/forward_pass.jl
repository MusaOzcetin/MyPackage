module ForwardPass

using ..Types
using ..CreateGenome

export forward_pass

"""
    forward_pass(genome::Genome, input::Vector{Float64}) → Float64

Compute the output of a simple feedforward network defined by `genome`.  
Handles input, bias, and output nodes. Supports any number of inputs or outputs (but assumes only one output).

# Arguments
- `genome::Genome`: The genome containing nodes and connections.
- `input::Vector{Float64}`: A vector of input values.

# Returns
- `Float64`: The sigmoid-activated output of the network (between 0 and 1).
"""
function forward_pass(genome::Genome, input::Vector{Float64})::Float64
    activations = Dict{Int, Float64}()

    # Assign input activations (sorted to match input order)
    input_ids = sort([id for (id, node) in genome.nodes if node.nodetype == :input])
    @assert length(input_ids) == length(input) "Mismatch between input nodes and values"
    for (i, id) in enumerate(input_ids)
        activations[id] = input[i]
    end

    # Bias node outputs 1.0
    for node in values(genome.nodes)
        if node.nodetype == :bias
            activations[node.id] = 1.0
        end
    end

    # Assume one output node
    output_id = first([id for (id, node) in genome.nodes if node.nodetype == :output])
    output_sum = 0.0

    for conn in values(genome.connections)
        if conn.enabled && conn.out_node == output_id
            source_activation = get(activations, conn.in_node, 0.0)
            output_sum += source_activation * conn.weight
        end
    end

    return 1.0 / (1.0 + exp(-output_sum))  # sigmoid
end

end