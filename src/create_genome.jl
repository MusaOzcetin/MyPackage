module CreateGenome

using ..Types
using ..Innovation: get_innovation_number  # <-- Add this line

export create_genome

"""
    create_genome(id::Int, num_inputs::Int, num_outputs::Int) → Genome

Creates a `Genome` with:
- The specified number of input nodes
- The specified number of output nodes
- Fully connected input-to-output connections with random weights

NO HIDDEN NODES ARE CREATED INITIALLY

# Arguments
- `id::Int`: Unique genome ID.
- `num_inputs::Int`: Number of input nodes.
- `num_outputs::Int`: Number of output nodes.

# Returns
- `Genome`: A new genome with nodes and fully connected input-output links.
"""
function create_genome(id::Int, num_inputs::Int, num_outputs::Int)::Genome
    nodes = Dict{Int, Node}()
    connections = Dict{Tuple{Int, Int}, Connection}()

    # Create input nodes
    for i in 1:num_inputs
        nodes[i] = Node(i, :input)
    end

    # Create output nodes (IDs continue after input nodes)
    for j in 1:num_outputs
        nid = num_inputs + j
        nodes[nid] = Node(nid, :output)
    end

    # Fully connect every input to every output with random weights
    for i in 1:num_inputs
        for j in 1:num_outputs
            out_id = num_inputs + j
            innovation = get_innovation_number(i, out_id)  # <-- Use proper innovation tracking
            connections[(i, out_id)] = Connection(i, out_id, randn(), true, innovation)
        end
    end

    return Genome(id, nodes, connections, 0.0, 0.0)
end

end # module