module Mutation

using ..Types
using Random

export mutate_weights!, mutate, add_connection!, add_node!

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
    add_connection!(genome::Genome)

Attempts to add a new connection between two previously unconnected nodes.

- Randomly selects two nodes from the genome.
- Ensures they are not already connected.
- Ensures the direction respects feedforward constraints (no output → input).
- Adds the new connection with a random weight and a new innovation number.

Does nothing if no valid pair is found after 50 attempts.

# Arguments
- `genome`: The genome to mutate (in-place).
"""
function add_connection!(genome::Genome)
    nodes = collect(values(genome.nodes))
    attempts = 0
    max_attempts = 50

    while attempts < max_attempts  #avoid Infinite loop
        in_node = rand(nodes)
        out_node = rand(nodes)

        if in_node.id == out_node.id       #two identical nodes
            attempts += 1
            continue
        end

        if in_node.nodetype == :output && out_node.nodetype == :input  #connection between output -> inout node
            attempts += 1
            continue
        end

        key = (in_node.id, out_node.id)

        if haskey(genome.connections, key)          #connection already exists
            attempts += 1
            continue
        end

        innovation_number =
            maximum([c.innovation_number for c in values(genome.connections)]) + 1
        genome.connections[key] = Connection(                               #create new connection
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

    new_innov = maximum([c.innovation_number for c in values(genome.connections)]) + 1
    genome.connections[(old_conn.in_node, new_node_id)] = Connection(
        old_conn.in_node, new_node_id, 1.0, true, new_innov
    ) #new connection old_node_a -> new node

    new_innov += 1
    return genome.connections[(new_node_id, old_conn.out_node)] = Connection(
        new_node_id, old_conn.out_node, old_conn.weight, true, new_innov
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
