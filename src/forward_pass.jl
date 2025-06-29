module ForwardPass

using ..Types

export forward_pass

"""
    forward_pass(genome::Genome, input::Vector{Float64}) → Dict{Int, Float64}

Performs a forward pass through the network defined by `genome`, computing activation values for all nodes.

# Arguments
- `genome::Genome`: The genome containing nodes and connections.
- `input::Vector{Float64}`: Activation values for input nodes.

# Returns
- `Dict{Int, Float64}`: A dictionary mapping each node ID to its activation value.
"""
function forward_pass(genome::Genome, input::Vector{Float64})::Dict{Int, Float64}
    # Determine evaluation order via topological sorting
    sorted_nodes = topological_sort(genome)

    # Identify and sort input nodes to align with provided input vector
    input_nodes = sort([n.id for n in values(genome.nodes) if n.nodetype == :input])

    # Prepare activation storage
    activations = Dict{Int, Float64}()

    # Assign provided values to input nodes in sorted order
    for (i, nid) in enumerate(input_nodes)
        activations[nid] = input[i]
    end

    # Gather enabled connections
    enabled_conns = [c for c in values(genome.connections) if c.enabled]

    # Compute activations for non-input nodes
    for node in sorted_nodes
        # Skip input nodes—they already have values
        if genome.nodes[node].nodetype == :input
            continue
        end

        # Sum weighted inputs
        sum_input = 0.0
        for conn in enabled_conns
            if conn.out_node == node
                sum_input += activations[conn.in_node] * conn.weight
            end
        end

        # Apply sigmoid activation function
        activations[node] = 1.0 / (1.0 + exp(-sum_input))
    end

    return activations
end

"""
    topological_sort(genome::Genome) → Vector{Int}

Performs a topological sort of all nodes in the `genome`.
The resulting order ensures each node appears only after all its predecessors have been processed.

# Arguments
- `genome::Genome`: The genome containing nodes and connections.

# Returns
- `Vector{Int}`: A list of node IDs in a valid computation order.

# Errors
- Throws an error if the graph contains cycles, making topological sorting impossible.
"""
function topological_sort(genome::Genome)::Vector{Int}
    # All node IDs
    nodes = collect(keys(genome.nodes))
    # Only consider enabled connections
    enabled_conns = [c for c in values(genome.connections) if c.enabled]

    # 1) Count in-degrees for each node
    in_degree = Dict(n => 0 for n in nodes)
    for conn in enabled_conns
        in_degree[conn.out_node] += 1
    end

    # 2) Initialize list of nodes with zero in-degree
    no_incoming = [n for n in nodes if in_degree[n] == 0]
    order = Int[]  # Sorted order container

    # Kahn's algorithm for topological sort
    while !isempty(no_incoming)
        n = popfirst!(no_incoming)
        push!(order, n)

        # Remove outgoing edges from n
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

    # 3) If not all nodes are processed, a cycle exists
    if length(order) != length(nodes)
        error("Graph contains cycles! Topological sort not possible.")
    end

    return order
end

end # module ForwardPass
