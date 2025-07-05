module Crossover

using ..Types
using ..ForwardPass
using Random
using ..CreateGenome: next_genome_id

export crossover

"""
    crossover(parent1::Genome, parent2::Genome) → Genome

Perform crossover between two parent genomes.  
The fitter parent contributes all disjoint and excess genes.  
Matching genes are randomly inherited from either parent.  
Disabled genes may remain disabled in the child.

# Arguments
- `parent1::Genome`: One parent genome.
- `parent2::Genome`: Another parent genome.

# Returns
- `Genome`: A new child genome composed from both parents' genes.
"""
function crossover(parent1::Genome, parent2::Genome)::Genome
    # Ensure parent1 is the fitter (or equal fitness: keep order)
    if parent2.fitness > parent1.fitness
        parent1, parent2 = parent2, parent1
    end

    # Prepare child structures
    child_nodes = Dict{Int,Node}()
    child_connections = Dict{Tuple{Int,Int},Connection}()

    # Map innovation_number => connection for quick lookup
    p1_innov = Dict(conn.innovation_number => conn for conn in values(parent1.connections))
    p2_innov = Dict(conn.innovation_number => conn for conn in values(parent2.connections))

    # Set of all innovation numbers from both parents
    all_innovs = union(keys(p1_innov), keys(p2_innov))

    for innov in all_innovs
        conn1 = get(p1_innov, innov, nothing)
        conn2 = get(p2_innov, innov, nothing)

        inherited_conn = nothing

        if conn1 !== nothing && conn2 !== nothing
            # Matching gene: randomly choose from either parent
            inherited_conn = rand(Bool) ? conn1 : conn2

            # If either is disabled, 75% chance to remain disabled
            if !conn1.enabled || !conn2.enabled
                inherited_conn = Connection(
                    inherited_conn.in_node,
                    inherited_conn.out_node,
                    inherited_conn.weight,
                    rand() > 0.75,  # 75% chance disabled
                    inherited_conn.innovation_number,
                )
            end

        elseif conn1 !== nothing
            # Disjoint/excess gene from fitter parent (parent1)
            inherited_conn = conn1
        end

        if inherited_conn !== nothing
            key = (inherited_conn.in_node, inherited_conn.out_node)
            child_connections[key] = Connection(
                inherited_conn.in_node,
                inherited_conn.out_node,
                inherited_conn.weight,
                inherited_conn.enabled,
                inherited_conn.innovation_number,
            )
        end
    end

    # Merge node dictionaries (union of all nodes used in both parents)
    all_nodes = merge(parent1.nodes, parent2.nodes)

    for (nid, node) in all_nodes
        child_nodes[nid] = Node(nid, node.nodetype)
    end
    # global cycle check
    try
        genome_try = Genome(next_genome_id(), child_nodes, child_connections, 0.0, 0.0)
        _ = ForwardPass.topological_sort(genome_try)
        return genome_try
    catch ex
        @warn "crossover: child contains cycles; crossover aborted" exception = ex
        return parent1
    end
end

end