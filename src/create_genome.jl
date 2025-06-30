module CreateGenome

using ..Types
<<<<<<< HEAD
export create_genome

"""
    create_genome(id::Int, num_inputs::Int, num_outputs::Int) → Genome

Creates a `Genome` with:
- The specified number of input nodes
- The specified number of output nodes
- Fully connected input-to-output connections with random weights

NO HIDDEN NODES ARE CREATED INITIALLY
=======

export create_genome

"""
    create_genome(id, num_inputs, num_outputs) → Genome

Instantiate a `Genome` with an `id`, `num_inputs` input nodes, and
`num_outputs` output nodes.  
Adds a bias node with constant output.  
Optionally creates connections from input and bias nodes to all output nodes.
>>>>>>> f610ce6 (Added bias and modified tests accordingly)

# Arguments
- `id::Int`: Unique genome ID.
- `num_inputs::Int`: Number of input nodes.
- `num_outputs::Int`: Number of output nodes.
- `deterministic::Bool`: If true, uses 1.0 as weight instead of random.
- `weight_map::Dict`: Optionally specify exact weights for some connections.
- `fully_connect::Bool`: If true, fully connects inputs/bias to outputs.

# Returns
<<<<<<< HEAD
- `Genome`: A new genome with nodes and fully connected input-output links.
"""
function create_genome(id::Int, num_inputs::Int, num_outputs::Int)::Genome
    nodes = Dict{Int, Node}()
    connections = Dict{Tuple{Int, Int}, Connection}()

    # Create input nodes
=======
A `Genome` with input, output, and bias nodes and optional initial connections.
"""
function create_genome(id::Int, num_inputs::Int, num_outputs::Int;
                       deterministic::Bool = false,
                       weight_map::Dict{Tuple{Int, Int}, Float64} = Dict(),
                       fully_connect::Bool = true)

    nodes = Dict{Int, Node}()
    connections = Dict{Tuple{Int, Int}, Connection}()
    node_id = 1

    # Add input nodes
>>>>>>> f610ce6 (Added bias and modified tests accordingly)
    for i in 1:num_inputs
        nodes[node_id] = Node(node_id, :input)
        node_id += 1
    end

<<<<<<< HEAD
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
=======
    # Add bias node
    bias_id = node_id
    nodes[bias_id] = Node(bias_id, :bias)
    node_id += 1

    # Add output nodes
    output_ids = node_id:(node_id + num_outputs - 1)
    for i in output_ids
        nodes[i] = Node(i, :output)
        node_id += 1
    end

    # Optionally connect input/bias nodes to outputs
    if fully_connect
        innovation = 1
        for in_id in 1:bias_id  # includes inputs and bias
            for out_id in output_ids
                weight = haskey(weight_map, (in_id, out_id)) ? weight_map[(in_id, out_id)] :
                         (deterministic ? 1.0 : randn())
                connections[(in_id, out_id)] = Connection(in_id, out_id, weight, true, innovation)
                innovation += 1
            end
>>>>>>> f610ce6 (Added bias and modified tests accordingly)
        end
    end

    return Genome(id, nodes, connections, 0.0, 0.0)
end

<<<<<<< HEAD

<<<<<<< HEAD
end # module

=======
end
>>>>>>> 09dfa74 (updated speciation.jl with adjusted fitness)
=======
end
>>>>>>> f610ce6 (Added bias and modified tests accordingly)
