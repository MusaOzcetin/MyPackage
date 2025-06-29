using Test
using Neat
<<<<<<< HEAD
using Neat.Mutation: causes_cycle, add_connection!, add_node!, mutate_weights!

@testset "Mutation tests" begin
    @testset "mutate_weights!" begin
        genome = create_genome(1, 2, 1)
        old_weights = [c.weight for c in values(genome.connections)]
        mutate_weights!(genome; perturb_chance=1.0, sigma=0.1)
        new_weights = [c.weight for c in values(genome.connections)]
        @test any(abs.(old_weights .- new_weights) .> 0)
    end

    @testset "add_connection! with hidden node" begin
        genome = create_genome(1, 2, 1)
        add_node!(genome)
        num_connections_before = length(genome.connections)
        add_connection!(genome)
        num_connections_after = length(genome.connections)
        @test num_connections_after >= num_connections_before
    end

    @testset "add_node!" begin
        genome = create_genome(1, 2, 1)
        num_nodes_before = length(genome.nodes)
        num_connections_before = length(genome.connections)
        add_node!(genome)
        num_nodes_after = length(genome.nodes)
        num_connections_after = length(genome.connections)
        @test num_nodes_after == num_nodes_before + 1
        @test num_connections_after == num_connections_before + 2

        num_disabled = count(!c.enabled for c in values(genome.connections))
        @test num_disabled == 1
    end

    @testset "mutate (full)" begin
        genome = create_genome(1, 2, 1)
        mutate(genome)
        @test length(genome.nodes) >= 3
        @test all(
            conn.in_node in keys(genome.nodes) && conn.out_node in keys(genome.nodes) for
            conn in values(genome.connections)
        )
    end
end
=======
using Neat.Mutation: causes_cycle, add_connection!
>>>>>>> ac9760e (fixed cycle logic and added mutation_test.jl)

@testset "add_connection! cycle prevention" begin
    genome = create_genome(1, 2, 1)

    # Apply many connection mutations
    for _ in 1:50
        add_connection!(genome)
    end

    # Function to check the entire graph for any cycles
    function has_cycle(genome::Genome)::Bool
        visited = Set{Int}()
        stack = Set{Int}()

        function visit(node_id::Int)
            if node_id in stack
                return true  # Found a cycle
            end
            if node_id in visited
                return false
            end
            push!(visited, node_id)
            push!(stack, node_id)

            for conn in values(genome.connections)
                if conn.enabled && conn.in_node == node_id
                    if visit(conn.out_node)
                        return true
                    end
                end
            end

            delete!(stack, node_id)
            return false
        end

        for node_id in keys(genome.nodes)
            if visit(node_id)
                return true
            end
        end
        return false
    end

    # TODO: delete this part before making it final
    println("Nodes in genome:")
<<<<<<< HEAD
    for (id, node) in genome.nodes
        println(" - ID $id : ", node.nodetype)
    end
    println("Connections in genome:")
    for ((src, dst), conn) in genome.connections
        println(" - $src → $dst (enabled=$(conn.enabled), weight=$(conn.weight))")
    end
=======
        for (id, node) in genome.nodes
    println(" - ID $id : ", node.nodetype)
        end
       println("Connections in genome:")
        for ((src, dst), conn) in genome.connections
    println(" - $src → $dst (enabled=$(conn.enabled), weight=$(conn.weight))")
        end
 
>>>>>>> ac9760e (fixed cycle logic and added mutation_test.jl)

    # Assert that no cycle exists after all mutations
    @test !has_cycle(genome)
end
