module Mutation

using ..Types
using ..Innovation
using Random

export mutate_weights!, mutate, add_connection!, add_node!, causes_cycle

"""
    mutate_weights!(genome; perturb_chance=0.8, sigma=0.5)

Mutates the weights of a genome's connections in-place.

- With `perturb_chance` probability: Perturb weight by adding N(0, sigma)
- Otherwise: Replace weight with a new random value (randn())
"""
function mutate_weights!(genome::Genome; perturb_chance=0.8, sigma=0.5)
    for conn in values(genome.connections)
        if rand() < perturb_chance
            conn.weight += randn() * sigma
        else
            conn.weight = randn()
        end
    end
end

"""
    causes_cycle(genome, src_id, dst_id)

Checks if adding a connection from `src_id` to `dst_id` would create a cycle.
"""
function causes_cycle(genome::Genome, src_id::Int, dst_id::Int)::Bool
    visited = Set{Int}()
    stack = [dst_id]

    while !isempty(stack)
        current = pop!(stack)
        if current == src_id
            return true
        end
        if current in visited
            continue
        end
        push!(visited, current)

        for conn in values(genome.connections)
            if conn.enabled && conn.in_node == current
                push!(stack, conn.out_node)
            end
        end
    end
    return false
end

"""
    add_connection!(genome::Genome)

Attempts to add a new connection between unconnected nodes.
Avoids invalid connections and cycles.
"""
function add_connection!(genome::Genome)
    nodes = collect(values(genome.nodes))
    attempts = 0
    max_attempts = 50

    while attempts < max_attempts
        possible_sources = filter(n -> n.nodetype in (:input, :bias, :hidden), nodes)
        possible_targets = filter(n -> n.nodetype in (:hidden, :output), nodes)

        if isempty(possible_sources) || isempty(possible_targets)
            return nothing
        end

        in_node = rand(possible_sources)
        out_node = rand(possible_targets)

        if in_node.id == out_node.id || in_node.nodetype == :output || out_node.nodetype == :input
            attempts += 1
            continue
        end

        key = (in_node.id, out_node.id)
        if haskey(genome.connections, key)
            attempts += 1
            continue
        end

        if causes_cycle(genome, in_node.id, out_node.id)
            attempts += 1
            continue
        end

        innovation_number = get_innovation_number(in_node.id, out_node.id)
        genome.connections[key] = Connection(
            in_node.id,
            out_node.id,
            randn(),
            true,
            innovation_number
        )
        return nothing
    end
end

"""
    add_node!(genome::Genome)

Inserts a new hidden node by splitting an existing active connection.
"""
function add_node!(genome::Genome)
    active_connections = [conn for conn in values(genome.connections) if conn.enabled]
    if isempty(active_connections)
        return nothing
    end

    old_conn = rand(active_connections)
    key = (old_conn.in_node, old_conn.out_node)

    # Disable old connection
    genome.connections[key] = Connection(
        old_conn.in_node,
        old_conn.out_node,
        old_conn.weight,
        false,
        old_conn.innovation_number
    )

    new_node_id = maximum(keys(genome.nodes)) + 1
    genome.nodes[new_node_id] = Node(new_node_id, :hidden)

    new_innov1 = get_innovation_number(old_conn.in_node, new_node_id)
    genome.connections[(old_conn.in_node, new_node_id)] = Connection(
        old_conn.in_node, new_node_id, 1.0, true, new_innov1
    )

    new_innov2 = get_innovation_number(new_node_id, old_conn.out_node)
    genome.connections[(new_node_id, old_conn.out_node)] = Connection(
        new_node_id, old_conn.out_node, old_conn.weight, true, new_innov2
    )
end

"""
    mutate(genome)

Applies all mutation operators to a genome.
"""
function mutate(genome::Genome)
    mutate_weights!(genome)
    if rand() < 0.3
        add_connection!(genome)
    end
    if rand() < 0.03
        add_node!(genome)
    end
end

end # module