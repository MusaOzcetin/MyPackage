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

# Arguments
- `genome`: The genome to mutate
- `perturb_chance`: Chance of small mutation vs full replacement
- `sigma`: Stddev of the perturbation
"""
function mutate_weights!(genome::Genome; perturb_chance=0.8, sigma=0.5)
    for conn in values(genome.connections)
        if rand() < perturb_chance
            conn.weight += randn() * sigma  # change curretn weight
        else
            conn.weight = randn()           # new random weight
        end
    end
end

"""
   HELPER: causes_cycle(genome, src_id, dst_id)

Checks if adding a connection from `src_id` to `dst_id` would create a cycle.
"""
function causes_cycle(genome::Genome, src_id::Int, dst_id::Int)::Bool
    visited = Set{Int}()
    stack = [dst_id]

    while !isempty(stack)
        current = pop!(stack)
        if current == src_id
            return true  # A path exists back to src → cycle would form
        end
        if current in visited
            continue
        end
        push!(visited, current)

        # Push all nodes that this node connects to (outgoing edges only)
        for (key, conn) in genome.connections
            if conn.enabled && conn.in_node == current
                push!(stack, conn.out_node)
            end
        end
    end
    return false
end


"""
    add_connection!(genome::Genome)

Attempts to add a new connection between two previously unconnected nodes.

- Randomly selects two nodes from the genome.
- Ensures they are not already connected.
- Ensures the direction respects feedforward constraints (no output → input).
- Checks for cycles
- Adds the new connection with a random weight and a new innovation number.

Does nothing if no valid pair is found after 50 attempts.

# Arguments
- `genome`: The genome to mutate (in-place).
"""
function add_connection!(genome::Genome)
    nodes = collect(values(genome.nodes))
    attempts = 0
    max_attempts = 50

    while attempts < max_attempts
        # Filter valid sources and targets
        possible_sources = filter(n -> n.nodetype in (:input, :bias, :hidden), nodes)
        possible_targets = filter(n -> n.nodetype in (:hidden, :output), nodes)

        # If no valid pairs, abort early
        if isempty(possible_sources) || isempty(possible_targets)
            return nothing
        end

        in_node = rand(possible_sources)
        out_node = rand(possible_targets)

        # Avoid self-loops
        if in_node.id == out_node.id
            attempts += 1
            continue
        end

        # Skip if connection already exists
        key = (in_node.id, out_node.id)
        if haskey(genome.connections, key)
            attempts += 1
            continue
        end

        # Avoid cycles
        if causes_cycle(genome, in_node.id, out_node.id)
            println("REJECTING connection $(in_node.id) -> $(out_node.id) due to cycle risk")
            attempts += 1
            continue
        end

        # Add the connection
        innovation_number = next_innovation_number()
        genome.connections[key] = Connection(
            in_node.id,
            out_node.id,
            randn(),
            true,
            innovation_number,
        )
        return nothing
    end
end


"""
    add_node!(genome::Genome)

Inserts a new hidden node by splitting an existing active connection.

- Randomly selects an enabled connection A → B.
- Disables the original connection.
- Creates a new hidden node C.
- Adds two new connections:
    - A → C (weight = 1.0)
    - C → B (inherits original weight)

This mutation allows the network to grow and change its topology.

# Arguments
- `genome`: The genome to mutate (in-place).
"""
function add_node!(genome::Genome)
    active_connections = [conn for conn in values(genome.connections) if conn.enabled]

    if isempty(active_connections) #
        return nothing
    end

    old_conn = rand(active_connections)         #choose random connection
    key = (old_conn.in_node, old_conn.out_node)

    genome.connections[key] = Connection(
        old_conn.in_node,
        old_conn.out_node,
        old_conn.weight,
        false,
        old_conn.innovation_number,
    ) #deactivate conenction

    existing_ids = collect(keys(genome.nodes))
    new_node_id = maximum(existing_ids) + 1
    genome.nodes[new_node_id] = Node(new_node_id, :hidden)      #create new genome

    new_innov1 = next_innovation_number()
    genome.connections[(old_conn.in_node, new_node_id)] = Connection(
        old_conn.in_node, new_node_id, 1.0, true, new_innov1
    ) #new connection old_node_a -> new node

    new_innov2 = next_innovation_number()
    return genome.connections[(new_node_id, old_conn.out_node)] = Connection(
        new_node_id, old_conn.out_node, old_conn.weight, true, new_innov2
    ) #new connection new node -> old_node_b
end

"""
    mutate(genome)

Applies all mutation operators to a genome.
"""
function mutate(genome::Genome)
    mutate_weights!(genome)
    if rand() < 0.05   #example value
        add_connection!(genome)
    end

    if rand() < 0.03 #example value
        add_node!(genome)
    end
end

end
