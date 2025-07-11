module CreateGenome

using ..Types
using ..Innovation
export create_genome
export next_genome_id
export reset_genome_id!

#global genome_id tracker
const genome_id_counter = Ref(0)

"""
    create_genome(num_inputs::Int, num_outputs::Int) → Genome

Creates a `Genome` with:
- The specified number of input nodes
- The specified number of output nodes
- Fully connected input-to-output connections with random weights

NO HIDDEN NODES ARE CREATED INITIALLY

# Arguments
- `num_inputs::Int`: Number of input nodes.
- `num_outputs::Int`: Number of output nodes.

# Returns
- `Genome`: A new genome with nodes and fully connected input-output links.
"""
function create_genome(num_inputs::Int, num_outputs::Int)
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
            innov_num = get_innovation_number(i, out_id)
            connections[(i, out_id)] = Connection(i, out_id, randn(), true, innov_num)
        end
    end

    return Genome(next_genome_id(), nodes, connections, 0.0, 0.0)
end

"""
    next_genome_id() → Int

Returns the next global node id.
"""
next_genome_id() = (genome_id_counter[] += 1; genome_id_counter[])

"""
    reset_id!()

Resets the counter (useful for tests).
"""
reset_genome_id!() = (genome_id_counter[] = 0)


end # module
