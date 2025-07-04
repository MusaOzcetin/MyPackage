module CreateGenome

using ..Types
export create_genome

"""
    create_genome(id::Int, num_inputs::Int, num_outputs::Int;
                  deterministic::Bool = false,
                  weight_map::Dict{Tuple{Int, Int}, Float64} = Dict(),
                  fully_connect::Bool = true) → Genome

Creates a `Genome` with:

- The specified number of input and output nodes
- A bias node with constant output
- Optionally creates fully connected input/bias → output connections
- You can provide deterministic weights or specific values via `weight_map`
- No hidden nodes are created initially

# Arguments
- `id`: Unique genome ID
- `num_inputs`: Number of input nodes
- `num_outputs`: Number of output nodes
- `deterministic`: If true, weights are set to `1.0` instead of random
- `weight_map`: Optional manual weights for specific (in, out) connections
- `fully_connect`: Whether to initialize fully connected input/output links

# Returns
- `Genome`: A complete genome with nodes and connections
"""
function create_genome(id::Int, num_inputs::Int, num_outputs::Int;
                       deterministic::Bool = false,
                       weight_map::Dict{Tuple{Int, Int}, Float64} = Dict(),
                       fully_connect::Bool = true)

    nodes = Dict{Int, Node}()
    connections = Dict{Tuple{Int, Int}, Connection}()
    node_id = 1

    # Add input nodes
    for i in 1:num_inputs
        nodes[node_id] = Node(node_id, :input)
        node_id += 1
    end

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
        end
    end

    return Genome(id, nodes, connections, 0.0, 0.0)
end

end # module
