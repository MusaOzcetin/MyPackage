module CreateGenome

using ..Types
export create_genome
export next_genome_id

#global genome_id tracker
const genome_id_counter = Ref(1)

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
    nodes = Dict{Int,Node}()
    connections = Dict{Tuple{Int,Int},Connection}()

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
    innov = 1  # Innovation numbers start at 1
    for i in 1:num_inputs
        for j in 1:num_outputs
            out_id = num_inputs + j
            connections[(i, out_id)] = Connection(i, out_id, randn(), true, innov)
            innov += 1
        end
    end

    # Added adjusted_fitness initialized to 0.0
    return Genome(next_genome_id(), nodes, connections, 0.0, 0.0)
end


"""
    next_genome_id() → Int

Returns the next global node id.
"""
function next_genome_id()::Int
    val = genome_id_counter[]
    genome_id_counter[] += 1
    return val
end

"""
    reset_id!()

Resets the counter (useful for tests).
"""
function reset_genome_id!()
    genome_id_counter[] = 1
end

end # module
