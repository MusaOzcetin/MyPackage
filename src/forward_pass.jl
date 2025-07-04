module ForwardPass

using ..Types

export forward_pass

"""
    forward_pass(genome::Genome, input::Vector{Float64}) → Dict{Int, Float64}

Performs a forward pass through the network defined by `genome`, computing activation values for all nodes.

Handles input, bias, and output nodes. Can handle any number of outputs and assumes a directed acyclic graph (DAG).

# Arguments
- `genome::Genome`: The genome containing nodes and connections.
- `input::Vector{Float64}`: A vector of input values (in sorted input-node order).

# Returns
- `Dict{Int, Float64}`: A dictionary mapping each node ID to its activation value.
"""
function forward_pass(genome::Genome, input::Vector{Float64})::Dict{Int, Float64}
    sorted_nodes = topological_sort(genome)

    input_nodes = sort([n.id for n in values(genome.nodes) if n.nodetype == :input])
    @assert length(input_nodes) == length(input) "Mismatch between input nodes and input vector size."

    activations = Dict{Int, Float64}()

    # Assign input values
    for (i, nid) in enumerate(input_nodes)
        activations[nid] = input[i]
    end

    # Bias node outputs 1.0
    for node in values(genome.nodes)
        if node.nodetype == :bias
            activations[node.id] = 1.0
        end
    end

    enabled_conns = [c for c in values(genome.connections) if c.enabled]

    for node_id in sorted_nodes
        node = genome.nodes[node_id]

        # Skip if input or bias node (already assigned)
        if node.nodetype in (:input, :bias)
            continue
        end

        # Compute weighted sum from incoming connections
        sum_input = 0.0
        for conn in enabled_conns
            if conn.out_node == node_id
                source_val = get(activations, conn.in_node, 0.0)
                sum_input += source_val * conn.weight
            end
        end

        # Sigmoid activation
        activations[node_id] = 1.0 / (1.0 + exp(-sum_input))
    end

    return activations
end

"""
    topological_sort(genome::Genome) → Vector{Int}

Performs a topological sort of all nodes in the `genome`.
Ensures valid computation order for a forward pass.

# Returns
- `Vector{Int}`: Ordered list of node IDs

# Throws
- `error` if the graph contains cycles
"""
function topological_sort(genome::Genome)::Vector{Int}
    nodes = collect(keys(genome.nodes))
    enabled_conns = [c for c in values(genome.connections) if c.enabled]

    in_degree = Dict(n => 0 for n in nodes)
    for conn in enabled_conns
        in_degree[conn.out_node] += 1
    end

    no_incoming = [n for n in nodes if in_degree[n] == 0]
    order = Int[]

    while !isempty(no_incoming)
        n = popfirst!(no_incoming)
        push!(order, n)

        for conn in enabled_conns
            if conn.in_node == n
                out = conn.out_node
                in_degree[out] -= 1
                if in_degree[out] == 0
                    push!(no_incoming, out)
                end
            end
        end
    end

    if length(order) != length(nodes)
        error("Graph contains cycles! Topological sort not possible.")
    end

    return order
end

end # module